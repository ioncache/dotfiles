dotfiles
========

'nix dotfiles

Well, it will probably work on a nix system.  It's actually mostly been tested on OSX, and some of the dependencies will only install automatically on OSX.

Table of contents
-----------------

- [dotfiles](#dotfiles)
  - [Table of contents](#table-of-contents)
  - [Installation](#installation)
  - [Setup Commands](#setup-commands)
  - [Dependencies](#dependencies)
  - [Post Install Manual Changes](#post-install-manual-changes)
  - [TODO](#todo)

<a name="installation"></a>
Installation
------------

```./setup.sh```

This will:
- backup all current dotfiles to `~/.dotfile_backups/<current timestamp>`
- install dependencies if possible
- generate a self-signed ssl cert and copy it to `~/`
- install new dotfiles to `~/`
- install new fonts to `~/Library/Fonts` on OSX or `~/.fonts` elsewhere

<a name="commands"></a>
Setup Commands
--------------

- `backup` - will backup current dotfiles to `~/.dotfile_backups/<current timestamp>`
- `deps` - will try to install dependencies
- `generate_ssl_cert` - will generate a self-signed ssl cert and copy the files to your home folder
- `install`: runs the `backup`, `deps` `generate_ssl_cert` `install_dotfiles`, `install_fonts` and `setup_git` targets -- **this is the default command**
- `install_bin` - will install new binaries to `~/bin`; `~/bin` is already added to the path in the included .bashrc
- `install_dotfiles` - will install the new dotfiles to `~/`
- `install_fonts` - will install new fonts to `~/Library/Fonts` or `~/.fonts` on other systems
- `restore` - will restore backed up dotfiles, usage `RESTORE_TIMESTAMP=<desired timestamp> ./setup.sh restore`
- `setup_git` - asks you to enter a name and email that will be used when making commits with git

<a name="dependencies"></a>
Dependencies
------------

Not completely necessary, but may be desired.  Will be installed by default if possible.

- autojump - a faster way to navigate your filesystem - https://github.com/wting/autojump
- bat - A cat(1) clone with wings - https://github.com/sharkdp/bat#installation
- ctags - this will only install on OSX as the BSD one installed is fairly outdated - https://github.com/universal-ctags/homebrew-universal-ctags
- exa - ls replacement - https://github.com/ogham/exa
- fd - A simple, fast and user-friendly alternative to 'find' - https://github.com/sharkdp/fd
- fzf - command-line fuzzy finder - https://github.com/junegunn/fzf
- git-extras - some extra commands for git - https://github.com/tj/git-extras
- gr - Multiple git repository management tool - https://github.com/mixu/gr
- homebrew - package management for OSX - https://brew.sh/
- jq - like sed for json - https://stedolan.github.io/jq/
- oh-my-git - git bash prompt - https://github.com/arialdomartini/oh-my-git
- vim-plug - vim plugin manager - https://github.com/junegunn/vim-plug

<a name="manual_changes"></a>
Post Install Manual Changes
---------------------------

1. change the font in your terminal to the newly installed `SourceCodePro+Powerline+Awesome`

<a name="todo"></a>
TODO
----

- allow for other flavours of linux than debian, eg, redhat
- make dependencies install correctly on linux -- mostly done
- install vim-plug plugins automatically
- if the dotfiles installed did not exist before the installation, then maybe the restore task should remove them; but this could have issues if the user subsequently added one of those files; maybe ask the user if they want the files removed
- ask user if they would like vim or emacs (or editor of their choice) to be their default editor in the EDITOR env variable
- make dependency installation interactive so user can choose which they want... maybe entire process could be interactive
