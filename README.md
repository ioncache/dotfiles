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
- install new fonts to `~/Library/Fonts` on OSX or `~/.fonts` elsewhere
- prompt for git name and email, then write `~/.gitconfig_custom`

## Setup Commands

- `backup` - will backup current dotfiles to `~/.dotfile_backups/<current timestamp>`
- `deps` - will try to install dependencies
- `dotfiles` - will install the new dotfiles to `~/`
- `fonts` - will install new fonts to `~/Library/Fonts` or `~/.fonts` on other systems
- `install` - runs `backup`, `deps`, `setup_git`, `dotfiles`, and `fonts` -- **this is the default command**
- `restore` - will restore backed up dotfiles, usage `RESTORE_TIMESTAMP=<desired timestamp> ./setup.sh restore`
- `setup_git` - asks you to enter a name and email that will be used when making commits with git

## Dependencies

Not completely necessary, but may be desired. Will be installed by default if possible.

- bat - A cat(1) clone with wings - <https://github.com/sharkdp/bat#installation>
- delta - syntax-highlighting pager for git and diff output - <https://github.com/dandavison/delta>
- ctags - this will only install on OSX as the BSD one installed is fairly outdated - <https://github.com/universal-ctags/homebrew-universal-ctags>
- eza - ls replacement - <https://github.com/eza-community/eza>
- fastfetch - system information tool - <https://github.com/fastfetch-cli/fastfetch>
- fd - A simple, fast and user-friendly alternative to 'find' - <https://github.com/sharkdp/fd>
- fzf - command-line fuzzy finder - <https://github.com/junegunn/fzf>
- git-extras - some extra commands for git - <https://github.com/tj/git-extras>
- homebrew - package management for OSX - <https://brew.sh/>
- jq - like sed for json - <https://stedolan.github.io/jq/>
- starship - cross shell prompt - <https://github.com/starship/starship>
- vim-plug - vim plugin manager - <https://github.com/junegunn/vim-plug>
- zoxide - smarter directory jumping - <https://github.com/ajeetdsouza/zoxide>

On apt-based Linux, `fastfetch` and `git-delta` are installed only when the package is available in the configured repositories.

## Post Install Manual Changes

1. change the font in your terminal to whichever font you like from the fonts folder.
   - please see instructions for your particular OS on how to do this

## TODO

- allow for other flavours of linux than debian, eg, redhat
- make dependencies install correctly on linux -- mostly done
- install vim-plug plugins automatically
- if the dotfiles installed did not exist before the installation, then maybe the restore task should remove them; but this could have issues if the user subsequently added one of those files; maybe ask the user if they want the files removed
- ask user if they would like vim or emacs (or editor of their choice) to be their default editor in the EDITOR env variable
- make dependency installation interactive so user can choose which they want... maybe entire process could be interactive
- **shell integration** - allow for shells other than `bash` to be used
