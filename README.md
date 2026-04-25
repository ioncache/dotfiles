# dotfiles

## Description

'nix dotfiles

Well, it will probably work on a nix system.  It's actually mostly been tested on OSX, and some of the dependencies will only install automatically on OSX.

## Table of Contents

- [dotfiles](#dotfiles)
  - [Description](#description)
  - [Table of Contents](#table-of-contents)
  - [Installation](#installation)
  - [Setup Commands](#setup-commands)
  - [Dependencies](#dependencies)
  - [Post Install Manual Changes](#post-install-manual-changes)
  - [TODO](#todo)

## Installation

```./setup.sh```

This will:

- backup all current dotfiles to `~/.dotfile_backups/<current timestamp>`
- install dependencies if possible
- install new dotfiles to `~/`
- install new fonts to `~/Library/Fonts` on macOS or `~/.local/share/fonts` elsewhere
- configure `~/.gitconfig_custom` from `GIT_NAME` and `GIT_EMAIL`, reuse an existing file, or prompt if needed

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

## Dependencies

Not completely necessary, but may be desired. Will be installed by default if possible.

### Base

- bat - A cat(1) clone with wings - <https://github.com/sharkdp/bat#installation>
- delta - syntax-highlighting pager for git and diff output - <https://github.com/dandavison/delta>
- ctags - this will only install on OSX as the BSD one installed is fairly outdated - <https://github.com/universal-ctags/homebrew-universal-ctags>
- eza - ls replacement - <https://github.com/eza-community/eza>
- fastfetch - system information tool - <https://github.com/fastfetch-cli/fastfetch>
- fd - A simple, fast and user-friendly alternative to 'find' - <https://github.com/sharkdp/fd>
- fzf - command-line fuzzy finder - <https://github.com/junegunn/fzf>
- git-extras - some extra commands for git - <https://github.com/tj/git-extras>
- btop - system monitor - <https://github.com/aristocratos/btop>
- homebrew - package management for OSX - <https://brew.sh/>
- jq - like sed for json - <https://stedolan.github.io/jq/>
- neovim - modern Vim-compatible editor - <https://neovim.io/>
- starship - cross shell prompt - <https://github.com/starship/starship>
- vim-plug - vim plugin manager - <https://github.com/junegunn/vim-plug>
- zoxide - smarter directory jumping - <https://github.com/ajeetdsouza/zoxide>

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

## Post Install Manual Changes

1. change the font in your terminal to whichever font you like from the fonts folder.
   - please see instructions for your particular OS on how to do this

## TODO

- allow for other flavours of linux than debian, eg, redhat
- make dependencies install correctly on linux -- mostly done
- install vim-plug plugins automatically
- if the dotfiles installed did not exist before the installation, then maybe the restore task should remove them; but this could have issues if the user subsequently added one of those files; maybe ask the user if they want the files removed
- ask user if they would like neovim or another editor to be their default editor in the EDITOR env variable
- add a more explicit guided mode for choosing optional package groups during install
- **shell integration** - allow for shells other than `bash` to be used
