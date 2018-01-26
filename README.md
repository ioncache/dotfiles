adotfiles
========

'nix dotfiles

Well, it will probably work on a nix system.  It's actually mostly been tested on OSX, and some of the dependencies will only install automatically on OSX.

Table of contents
-----------------

- [Installation](#installation)
- [Make Targets](#targets)
- [Dependencies](#dependencies)
- [Post Install Manual Changes](#manual_changes)
- [TODO](#todo)

<a name="installation"></a>
Installation
------------

```make```

This will:
- backup all current dotfiles to `~/.dotfile_backups/<current timestamp>`
- install dependencies if possible
- install new dotfiles to `~/`
- install new fonts to `~/Library/Fonts` (OSX only for fonts right now)

<a name="targets"></a>
Make Targets
------------

- `default target`: runs the `backup`, `deps` `generate_ssl_cert` and `install` targets
- `backup` - will backup current dotfiles to `~/.dotfile_backups/<current timestamp>`
- `deps` - will try to install dependencies
- `generate_ssl_cert` - will generate a self-signed ssl cert and copy the files to your home folder
- `install` - will run the `install_dotfiles` and `install_fonts` targets
- `install_bin` - will install new binaries to `~/bin`; `~/bin` is already added to the path in the included .bashrc
- `install_dotfiles` - will install the new dotfiles to `~/`
- `install_fonts` - will install new fonts to `~/Library/Fonts` (OSX only for fonts right now)
- `restore` - will restore backed up dotfiles, usage `make restore RESTORE_TIMESTAMP=<desired timestamp>`

<a name="dependencies"></a>
Dependencies
------------

Not completely necessary, but may be desired.  Will be installed by default if possible.

- exa - ls replacement - https://github.com/ogham/exa
- fzf - fuzzy finder - https://github.com/junegunn/fzf
- git-extras - some extra commands for git - https://github.com/tj/git-extras
- gr - Multiple git repository management tool - https://github.com/mixu/gr
- oh-my-git - git bash prompt - https://github.com/arialdomartini/oh-my-git
- vim-plug - vim plugin manager - https://github.com/junegunn/vim-plug

<a name="manual_changes"></a>
Post Install Manual Changes
---------------------------

1. add a custom .gitconfig for setting git name and email and any other settings that the user desires
  - `vim ~/.gitconfig_custom`
  - insert the following into the file:

```
[user]
  name = <your name>
  email = <your email>
```

2. change the font in your terminal to the newly installed `SourceCodePro+Powerline+Awesome`

<a name="todo"></a>
TODO
----

- install fonts in correct place on linux
- make dependencies install correctly on linux
- make dependencies upgrade existing installed versions possibly
- install vim-plug plugins automatically
- do something other than the silly make file... or at least use less bash in the file and more make style commands
- if the dotfiles installed did not exist before the installation, then maybe the restore task should remove them; but this could have issues if the user subsequently added one of those files; maybe ask the user if they want the files removed
- ask user if they would like vim or emacs (or editor of their choice) to be their default editor in the EDITOR env variable
