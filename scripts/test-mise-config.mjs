import assert from 'node:assert/strict';
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { spawnSync } from 'node:child_process';
import { test } from 'node:test';
import { fileURLToPath } from 'node:url';

const repo = fileURLToPath(new URL('../', import.meta.url));
const mise = process.env.MISE_TEST_BIN ?? 'mise';

function write(home, path, content, mode = 0o644) {
  const destination = join(home, path);
  mkdirSync(dirname(destination), { recursive: true });
  writeFileSync(destination, content, { mode });
}

function run(fixture, command, args, extraEnv = {}) {
  const result = spawnSync(command, args, {
    cwd: fixture.home,
    env: { ...fixture.env, ...extraEnv },
    encoding: 'utf8',
    timeout: 15000,
  });
  assert.ifError(result.error);
  assert.equal(result.status, 0, result.stderr || result.stdout);
  return result.stdout.trim();
}

function fixture(t, globalFile = '.config/mise/config.toml') {
  const home = mkdtempSync(join(tmpdir(), 'dotfiles-mise-config-'));
  t.after(() => rmSync(home, { recursive: true, force: true }));
  const result = {
    home,
    globalFile: join(home, globalFile),
    env: {
      HOME: home,
      PATH: process.env.PATH,
      XDG_CONFIG_HOME: join(home, '.config'),
      XDG_DATA_HOME: join(home, '.local/share'),
      XDG_CACHE_HOME: join(home, '.cache'),
      XDG_STATE_HOME: join(home, '.local/state'),
      MISE_TEST_BIN: mise,
      SCRIPT_DIR: repo,
      OS: 'Linux',
    },
  };
  if (globalFile !== '.config/mise/config.toml') {
    result.env.MISE_GLOBAL_CONFIG_FILE = result.globalFile;
  }
  write(home, globalFile, `[tools]
node = "22.23.4"
"npm:npm-check-updates" = "23.1.1"
"npm:snyk" = "1.1308.4"
`);
  write(home, '.volta/bin/volta', '#!/bin/sh\nprintf "runtime node@24.11.1 (default)\\n"\n', 0o755);
  for (const version of ['22.23.4', '24.11.1', '20.20.0']) {
    write(home, `linked/node-${version}/bin/node`, `#!/bin/sh\nprintf "v${version}\\n"\n`, 0o755);
    run(result, mise, ['link', `node@${version}`, join(home, `linked/node-${version}`)]);
  }
  for (const [tool, version, bin] of [['npm-check-updates', '23.1.1', 'ncu'], ['snyk', '1.1308.4', 'snyk']]) {
    write(home, `linked/${tool}/bin/${bin}`, '#!/bin/sh\nexit 0\n', 0o755);
    run(result, mise, ['link', `npm:${tool}@${version}`, join(home, `linked/${tool}`)]);
  }
  return result;
}

function provision(fixture, extraEnv = {}) {
  run(fixture, '/bin/bash', ['--noprofile', '--norc', '-c', `
. "$SCRIPT_DIR/lib/install_packages.sh"
mise() { command "$MISE_TEST_BIN" "$@"; }
install_node_tools
`], extraEnv);
}

test('a session Node override cannot replace the saved global default', (t) => {
  const state = fixture(t);
  provision(state, { MISE_NODE_VERSION: '20.20.0' });
  assert.equal(run(state, mise, ['config', 'get', '--global', 'tools.node']), '22.23.4');
});

test('global provisioning ignores project configuration in the home directory', (t) => {
  const state = fixture(t);
  write(state.home, 'mise.toml', '[tools]\nnode = "20.20.0"\n[settings]\nidiomatic_version_file_enable_tools = ["go"]\n');
  run(state, mise, ['trust', join(state.home, 'mise.toml')]);
  provision(state);
  assert.equal(run(state, mise, ['config', 'get', '--global', 'tools.node']), '22.23.4');
  assert.doesNotMatch(readFileSync(state.globalFile, 'utf8'), /"go"/);
});

test('enabling Node version files preserves languages configured in global fragments', (t) => {
  const state = fixture(t);
  write(state.home, '.config/mise/conf.d/languages.toml', '[settings]\nidiomatic_version_file_enable_tools = ["python", "ruby"]\n');
  provision(state);
  const languages = JSON.parse(run(state, mise, ['settings', '--json', 'idiomatic_version_file_enable_tools']));
  assert.deepEqual(languages.sort(), ['node', 'python', 'ruby']);
});

test('a session language override does not become persistent configuration', (t) => {
  const state = fixture(t);
  write(state.home, '.config/mise/conf.d/languages.toml', '[settings]\nidiomatic_version_file_enable_tools = ["python", "ruby"]\n');
  provision(state, { MISE_IDIOMATIC_VERSION_FILE_ENABLE_TOOLS: 'go' });
  const languages = JSON.parse(run(state, mise, ['settings', '--json', 'idiomatic_version_file_enable_tools']));
  assert.deepEqual(languages.sort(), ['node', 'python', 'ruby']);
});

test('custom global config locations and repeated setup preserve existing requests', (t) => {
  const state = fixture(t, 'custom-mise/settings.toml');
  provision(state, { MISE_NODE_VERSION: '20.20.0' });
  assert.equal(run(state, mise, ['config', 'get', '--global', 'tools.node']), '22.23.4');
  const config = readFileSync(state.globalFile, 'utf8');
  provision(state, { MISE_NODE_VERSION: '24.11.1' });
  assert.equal(readFileSync(state.globalFile, 'utf8'), config);
});
