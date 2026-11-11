import assert from 'node:assert/strict';
import { copyFileSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { spawnSync } from 'node:child_process';
import { test } from 'node:test';
import { fileURLToPath } from 'node:url';

const repo = fileURLToPath(new URL('../', import.meta.url));
const miseStub = `#!/bin/sh
printf '%s|%s\\n' "$PWD" "$*" >> "$HOME/mise-calls"
case "$1" in
  activate)
    if [ "$3" = --shims ]; then
      printf 'export PATH="$HOME/.local/share/mise/shims:$PATH"\\n'
    else
      printf 'export PATH="$HOME/mise-node/bin:$PATH"\\n'
    fi
    ;;
  ls)
    grep -Fx "$5" "$HOME/configured-tools" 2>/dev/null || true
    ;;
  use)
    exit "\${TEST_INSTALL_EXIT:-0}"
    ;;
  settings)
    if [ "$2" = --json ]; then
      printf '[]\\n'
    fi
    ;;
esac
`;

function write(home, path, content, mode = 0o644) {
  const destination = join(home, path);
  mkdirSync(dirname(destination), { recursive: true });
  writeFileSync(destination, content, { mode });
}

function fixture(t) {
  const home = mkdtempSync(join(tmpdir(), 'dotfiles-runtime-'));
  t.after(() => rmSync(home, { recursive: true, force: true }));
  for (const name of ['.bash_profile', '.bashrc', '.profile', '.shell_common', '.zprofile', '.zshrc']) {
    copyFileSync(join(repo, 'dotfiles', name), join(home, name));
  }
  write(home, '.ohmyzshrc', '');
  write(home, 'bin/uname', '#!/bin/sh\nprintf "Linux\\n"\n', 0o755);
  for (const name of ['starship', 'direnv', 'zoxide', 'gr', 'npm', 'brew']) {
    write(home, `bin/${name}`, '#!/bin/sh\nexit 0\n', 0o755);
  }
  write(home, 'bin/jq', '#!/bin/sh\nprintf "node\\n"\n', 0o755);
  write(home, '.volta/bin/node', '#!/bin/sh\nprintf "volta-node\\n"\n', 0o755);
  write(home, '.volta/bin/volta', `#!/bin/sh
printf '%s\\n' "$*" >> "$HOME/volta-calls"
printf 'runtime node@22.23.4 (default)\\n'
`, 0o755);
  return home;
}

function addMise(home) {
  write(home, '.local/bin/mise', miseStub, 0o755);
  write(home, 'mise-node/bin/node', '#!/bin/sh\nprintf "mise-node\\n"\n', 0o755);
  write(home, '.local/share/mise/shims/node', '#!/bin/sh\nprintf "mise-shim\\n"\n', 0o755);
}

function run(home, script, options = {}) {
  const shell = options.shell ?? 'bash';
  const flags = shell === 'zsh' ? ['-d', '-f'] : ['--noprofile', '--norc'];
  const result = spawnSync(shell, [...flags, '-c', `
command() {
  if [ "$1" = -v ] && [ "$2" = mise ]; then
    for candidate in "$HOME/.local/bin/mise" "$HOME/bin/mise"; do
      if [ -x "$candidate" ]; then
        printf '%s\\n' "$candidate"
        return
      fi
    done
    return 1
  else
    builtin command "$@"
  fi
}
${script}
`], {
    cwd: repo,
    env: {
      HOME: home,
      PATH: `${home}/bin:/usr/bin:/bin`,
      TERM: 'dumb',
      SCRIPT_DIR: repo,
      OS: 'Linux',
      ...options.env,
    },
    encoding: 'utf8',
    timeout: 15000,
  });
  assert.ifError(result.error);
  assert.equal(result.status, options.status ?? 0, result.stderr || result.stdout);
  return result.stdout.trim();
}

function provision(home, options) {
  return run(home, '. "$SCRIPT_DIR/lib/install_packages.sh"; install_node_tools', options);
}

function calls(home) {
  return readFileSync(join(home, 'mise-calls'), 'utf8');
}

for (const shell of ['bash', 'zsh']) {
  const rc = shell === 'bash' ? '.bashrc' : '.zshrc';
  const profile = shell === 'bash' ? '.bash_profile' : '.zprofile';

  test(`${shell} prefers mise over an inherited Volta PATH`, (t) => {
    const home = fixture(t);
    addMise(home);
    const output = run(home, `PS1='$ '; . "$HOME/${rc}"; node`, {
      shell,
      env: { PATH: `${home}/.volta/bin:${home}/bin:/usr/bin:/bin` },
    });
    assert.equal(output, 'mise-node');
    assert.match(calls(home), new RegExp(`activate ${shell}\\n`));
  });

  test(`${shell} falls back to Volta without mise`, (t) => {
    const home = fixture(t);
    assert.equal(run(home, `PS1='$ '; . "$HOME/${rc}"; node`, { shell }), 'volta-node');
  });

  test(`${shell} login profile exposes shims without interactive activation`, (t) => {
    const home = fixture(t);
    addMise(home);
    assert.equal(run(home, `unset PS1; . "$HOME/${profile}"; node`, { shell }), 'mise-shim');
    assert.equal(calls(home), `${repo.replace(/\/$/, '')}|activate ${shell} --shims\n`);
  });
}

test('Volta fallback respects a custom VOLTA_HOME', (t) => {
  const home = fixture(t);
  write(home, 'custom-volta/bin/node', '#!/bin/sh\nprintf "custom-volta\\n"\n', 0o755);
  assert.equal(run(home, 'PS1=test; . "$HOME/.bashrc"; node', {
    env: { VOLTA_HOME: join(home, 'custom-volta') },
  }), 'custom-volta');
});

test('provisioning preserves the Volta default and installs both npm CLIs globally', (t) => {
  const home = fixture(t);
  addMise(home);
  provision(home);
  const log = calls(home);
  assert.match(log, /use --global node@22\.23\.4\n/);
  assert.match(log, /use --global npm:npm-check-updates@latest\n/);
  assert.match(log, /use --global npm:snyk@latest\n/);
  assert.match(log, /settings set idiomatic_version_file_enable_tools node\n/);
  assert.ok(log.trim().split('\n').every((line) => line.startsWith(`${home}|`)));
  assert.equal(readFileSync(join(home, 'volta-calls'), 'utf8'), 'list --default --format plain node\n');
});

test('existing mise requests are installed without rewriting them or consulting Volta', (t) => {
  const home = fixture(t);
  addMise(home);
  write(home, 'configured-tools', 'node\nnpm:npm-check-updates\nnpm:snyk\n');
  write(home, '.volta/bin/volta', '#!/bin/sh\nexit 71\n', 0o755);
  provision(home);
  assert.doesNotMatch(calls(home), /use --global/);
  for (const tool of ['node', 'npm:npm-check-updates', 'npm:snyk']) {
    assert.ok(calls(home).includes(`|install ${tool}\n`));
  }
});

test('a fresh installation selects Node LTS without installing Volta', (t) => {
  const home = fixture(t);
  addMise(home);
  rmSync(join(home, '.volta/bin/volta'));
  provision(home);
  assert.match(calls(home), /use --global node@lts\n/);
});

test('an installed Volta with no default Node version also selects LTS', (t) => {
  const home = fixture(t);
  addMise(home);
  write(home, '.volta/bin/volta', '#!/bin/sh\nexit 0\n', 0o755);
  provision(home);
  assert.match(calls(home), /use --global node@lts\n/);
});

test('a Node installation failure stops before settings or npm tools change', (t) => {
  const home = fixture(t);
  addMise(home);
  provision(home, { env: { TEST_INSTALL_EXIT: '73' }, status: 73 });
  assert.doesNotMatch(calls(home), /settings|npm:/);
});

for (const os of ['Darwin', 'Linux']) {
  test(`${os} bootstraps mise with the appropriate installer`, (t) => {
    const home = fixture(t);
    write(home, 'mise-stub', miseStub);
    const installScript = 'mkdir -p "$HOME/.local/bin"; cp "$HOME/mise-stub" "$HOME/.local/bin/mise"; chmod +x "$HOME/.local/bin/mise"';
    write(home, 'bin/brew', `#!/bin/sh
printf '%s\\n' "$*" >> "$HOME/brew-calls"
cp "$HOME/mise-stub" "$HOME/bin/mise"
chmod +x "$HOME/bin/mise"
`, 0o755);
    write(home, 'bin/curl', `#!/bin/sh
printf '%s\\n' "$*" >> "$HOME/curl-calls"
printf '%s\\n' '${installScript}'
`, 0o755);
    provision(home, { env: { OS: os } });
    const installer = os === 'Darwin' ? 'brew' : 'curl';
    const expected = os === 'Darwin' ? 'install mise\n' : '-fsSL https://mise.run\n';
    assert.equal(readFileSync(join(home, `${installer}-calls`), 'utf8'), expected);
    assert.match(calls(home), /use --global node@22\.23\.4\n/);
  });
}

test('a failed mise download propagates instead of appearing successful through the pipe', (t) => {
  const home = fixture(t);
  write(home, 'bin/curl', '#!/bin/sh\nexit 22\n', 0o755);
  provision(home, { status: 22 });
});

for (const target of ['deps', 'install']) {
  test(`setup ${target} reports dependency failures instead of continuing`, (t) => {
    const home = fixture(t);
    copyFileSync(join(repo, 'setup.sh'), join(home, 'setup.sh'));
    write(home, 'lib/install_packages.sh', 'deps() { return 73; }\n');
    write(home, 'lib/install_dotfiles.sh', 'backup() { :; }\ndotfiles() { echo unexpected; }\n');
    write(home, 'lib/install_bin.sh', 'bin_scripts() { echo unexpected; }\n');
    write(home, 'lib/install_fonts.sh', 'fonts() { echo unexpected; }\n');
    write(home, 'lib/setup_git.sh', 'setup_git() { echo unexpected; }\n');
    assert.equal(run(home, `bash "$HOME/setup.sh" ${target}`, { status: 73 }), '');
  });
}
