# dotfiles

## Description

Personal shell, editor, and terminal dotfiles for macOS and apt-based Linux systems.

The setup flow is primarily exercised on macOS, but the repo also supports Debian-family Linux with a separate apt-based dependency path.

## Table of Contents

- [dotfiles](#dotfiles)
  - [Description](#description)
  - [Table of Contents](#table-of-contents)
  - [Installation](#installation)
  - [Setup Commands](#setup-commands)
  - [Development Tooling](#development-tooling)
  - [Dependencies](#dependencies)
    - [Base](#base)
    - [Optional Infra And Cloud Groups](#optional-infra-and-cloud-groups)

## Installation

```bash
./setup.sh
```

This will:

- backup all current dotfiles to `~/.dotfile_backups/<current timestamp>`
- install dependencies if possible
- install new dotfiles to `~/`
- install new fonts to `~/Library/Fonts` on macOS or `~/.local/share/fonts` elsewhere
- configure `~/.gitconfig_custom` from `GIT_NAME` and `GIT_EMAIL`, reuse an existing file, or prompt if needed

After installation, set your terminal font to one of the patched fonts from the repo's `fonts/` directory.

## Setup Commands

- `backup` - will backup current dotfiles to `~/.dotfile_backups/<current timestamp>`
- `deps` - will install the base dependency set
- `deps <group...>` - will install the base dependency set plus optional package groups, for example `./setup.sh deps azure kubernetes`
- `dotfiles` - will install the new dotfiles to `~/`
- `fonts` - will install new fonts to `~/Library/Fonts` on macOS or `~/.local/share/fonts` on other systems
- `groups` - will list the optional package groups available for the current OS
- `install` - runs `backup`, `deps`, `setup_git`, `dotfiles`, and `fonts` -- **this is the default command**
- `install <group...>` - runs the default install flow and also installs optional package groups
- `restore` - will restore backed up dotfiles, usage `RESTORE_TIMESTAMP=<desired timestamp> ./setup.sh restore`
- `setup_git` - configures git identity from environment, existing config, or a prompt when needed

For unattended setup, use `NONINTERACTIVE=1` and preseed git identity:

- `NONINTERACTIVE=1 GIT_NAME='Jane Doe' GIT_EMAIL='jane@example.com' ./setup.sh install`

## Development Tooling

Install repo-local development tooling with `npm install`.

See [docs/development.md](docs/development.md) for the local development workflow.

- `npm run lint` is the umbrella lint entrypoint and runs shell plus Markdown linting.
- `npm run lint:md` runs `markdownlint-cli2` for repo Markdown files.
- `npm run lint:shell` runs `shellcheck` against bash and sh files and `zsh -n` against zsh-specific files.
- `npm run lint:shell:staged` runs the staged-file version used by `pre-commit`.
- `husky` and `lint-staged` run the same shell and Markdown lint checks during `pre-commit` for staged files.

## Dependencies

These are the base tools the installer attempts to install by default when the current platform supports them.

On macOS, the installer bootstraps Homebrew if needed and uses it to install the base package set.

### Base

- bat - syntax-highlighting `cat` replacement - <https://github.com/sharkdp/bat#installation>
- delta - syntax-highlighting pager for Git and diff output - <https://github.com/dandavison/delta>
- ctags - `universal-ctags`, installed via Homebrew on macOS - <https://github.com/universal-ctags/homebrew-universal-ctags>
- eza - modern `ls` replacement - <https://github.com/eza-community/eza>
- fastfetch - system information tool - <https://github.com/fastfetch-cli/fastfetch>
- fd - fast, user-friendly `find` alternative - <https://github.com/sharkdp/fd>
- fzf - command-line fuzzy finder - <https://github.com/junegunn/fzf>
- git-extras - additional Git subcommands - <https://github.com/tj/git-extras>
- btop - interactive system monitor - <https://github.com/aristocratos/btop>
- jq - command-line JSON processor - <https://stedolan.github.io/jq/>
- neovim - modern Vim-compatible editor - <https://neovim.io/>
- starship - cross-shell prompt - <https://github.com/starship/starship>
- vim-plug - Vim and Neovim plugin manager - <https://github.com/junegunn/vim-plug>
- zoxide - smarter directory jumper - <https://github.com/ajeetdsouza/zoxide>

On apt-based Linux, `fastfetch` and `git-delta` are installed only when the package is available in the configured repositories.

On Debian-family Linux, the shell config also normalizes a couple of common package-name differences when needed:

- `batcat` is aliased to `bat`
- `fdfind` is aliased to `fd`

The installer also attempts a best-effort Linux install of `starship` when it is available via apt.

Neovim is now the default editor. For fresh installs, `~/.config/nvim/init.vim` sources the shared `~/.vimrc`, so the core configuration works in both Vim and Neovim while the default editor command path uses `nvim`.

If `~/.config/nvim/init.lua` already exists, the installer preserves it and skips the repo's `init.vim` shim to avoid Neovim's conflicting-config error.

Shell completions are now configured per shell instead of through the shared runtime. Bash loads Homebrew `bash_completion.d` scripts from `.bashrc`, while zsh uses Homebrew's native `share/zsh/site-functions` completions with `compinit` from `.zshrc`.

The old `j` muscle-memory command is kept as a compatibility alias backed by `zoxide`.

### Optional Infra And Cloud Groups

Use `./setup.sh groups` to list the groups available for the current OS.

- `azure` - Azure CLI tools
- `aws` - AWS CLI tools
- `gcp` - Google Cloud CLI tools
- `digitalocean` - DigitalOcean CLI tools
- `kubernetes` - cluster tooling such as `kubectl`, `helm`, and `k9s`
- `containers` - container tooling such as Docker CLI-related packages
- `local-runtime-macos` - macOS-only local runtime tools such as OrbStack

Examples:

- `./setup.sh deps azure kubernetes`
- `./setup.sh install aws containers`
- `./setup.sh install digitalocean local-runtime-macos`
