# Development

## Installation

```bash
git clone https://github.com/ioncache/dotfiles.git
cd dotfiles
npm install
```

## Linting

```bash
npm run lint
```

This runs the repo lint suite:

- `shellcheck` for bash and sh-oriented files
- `zsh -n` for zsh-specific files
- `markdownlint-cli2` for Markdown files

To run the staged-file variant used by pre-commit:

```bash
npm run lint:shell:staged
```

## Git Hooks

`husky` installs the repo hooks during `npm install` via the `prepare` script.

The `pre-commit` hook runs `lint-staged`, which applies shell linting only to staged shell files.

## Safe Shell Change Validation

Run the runtime regression tests without installing tools or changing your real home directory:

```bash
npm test
```

These tests use temporary homes and stubbed commands to cover mise precedence, Volta fallback, login shims, migration defaults, and installer failures. Bash and Zsh must be installed.

Run the configuration-preservation regressions with mise and jq installed:

```bash
npm run test:mise
```

These tests use the real mise CLI with isolated home directories and linked fake tools. They do not download runtimes or change your mise configuration. They cover session overrides, home-directory project configuration, global fragments, custom global config files, and repeated setup. Set `MISE_TEST_BIN` to an absolute executable path to test a mise installation that is not on PATH.

For narrow local checks while iterating:

```bash
for file in setup.sh lib/*.sh dotfiles/.bash_profile dotfiles/.bashrc dotfiles/.profile dotfiles/.shell_common; do
  bash -n "$file"
done
for file in dotfiles/.zprofile dotfiles/.zshrc dotfiles/.ohmyzshrc; do
  zsh -n "$file"
done
```

## Applying Dotfile Changes Locally

To install the repo-managed dotfiles into your home directory:

```bash
./setup.sh dotfiles
```

To run the full unattended install flow:

```bash
NONINTERACTIVE=1 GIT_NAME='Jane Doe' GIT_EMAIL='jane@example.com' ./setup.sh install
```
