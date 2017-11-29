dotfiles
========

'nix dotfiles

Well, it will probably work on a nix system.  It's actually mostly been tested on OSX, and some of the dependencies will only install automatically on OSX.

Table of contents
-----------------

- [Installation](#installation)
- [Make Targets](#targets)
- [Dependencies](#dependencies)
- [TODO](#todo)

<a name="installation"></a>
Installation
------------

```make```

This will:
- backup all current dotfiles to `~/.dotfile_backups/<current timestamp>`
- install dependencies if possible
- install new dotfiles to `~/`

<a name="targets"></a>
Make Targets
------------

- `backup` - will backup current dotfiles to `~/.dotfile_backups/<current timestamp>`
- `deps` - will try to install dependencies
- `install` - will install the new dotfiles to `~/`
- `restore` - will restore backed up dotfiles, usage `make restore RESTORE_TIMESTAMP=<desired timestamp>`

<a name="dependencies"></a>
Dependencies
------------

Not completely necessary, but may be desired.  Will be installed by default if possible.

- exa - ls replacement - https://github.com/ogham/exa
- fzf - fuzzy finder - https://github.com/junegunn/fzf
- oh-my-git - git bash prompt - https://github.com/arialdomartini/oh-my-git
- vim-plug - vim plugin manager - https://github.com/junegunn/vim-plug

<a name="todo"></a>
TODO
----

- install bin files in ~/bin (~/bin is already added to path in .bashrc)
- install fonts in correct place
- make dependencies install correctly on linux
- make dependencies upgrade existing installed versions possibly
- install vim-plug plugins automatically
- do something other than the silly make file... or at least use less bash in the file and more make style commands
