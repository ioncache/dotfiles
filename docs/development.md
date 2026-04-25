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

For narrow local checks while iterating:

```bash
bash -n setup.sh lib/*.sh dotfiles/.bash_profile dotfiles/.bashrc dotfiles/.profile dotfiles/.shell_common
zsh -n dotfiles/.zshrc dotfiles/.ohmyzshrc
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
