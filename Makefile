########################################################################
# ioncache Dotfile Makefile
########################################################################

# why on earth did I do this as a Makefile?  I hate Makefiles.

OS 					   		 = $(shell uname -s)
FILELIST			 		 = .bash_profile .bashrc .git-completion.sh .gitconfig .gitignore .htoprc .perlcriticrc .perltidyrc .profile .screenrc .tmux.conf .vimrc
MAKE_TIMESTAMP     = $(shell date +%s)``
RESTORE_TIMESTAMP ?= 'notarealbackupttimestamp'

##### Default actions when running make -- makes the base api package
.PHONY: main
main: backup deps install

.PHONY: install
install:
	@echo
	@echo '***** Installing new Dotfiles *****'
	@echo

	@for f in $(FILELIST) ; \
	do \
		echo "\tinstalling $$f" ; \
		cp ./$$f ~/ ; \
	done ;

.PHONY: backup
backup:
	@echo
	@echo '***** Backing up current Dotfiles *****'
	@echo

	@if [ ! -d ~/.dotfile_backups ] ; then \
		mkdir ~/.dotfile_backups ; \
	fi;

	@if [ ! -d ~/.dotfile_backups/$(MAKE_TIMESTAMP) ] ; then \
		mkdir ~/.dotfile_backups/$(MAKE_TIMESTAMP) ; \
	fi;

	@for f in $(FILELIST) ; \
	do \
		if [ -f ~/$$f ] ; then \
			echo "\tbacking up $$f" ; \
			cp ~/$$f ~/.dotfile_backups/$(MAKE_TIMESTAMP) ; \
		fi ; \
	done ;

.PHONY: deps
deps:
	@echo
	@echo '***** Installing Dependencies *****'
	@echo

	@if [ -x "$$(command -v brew)" ] ; then \
		if [ ! -x "$$(command -v exa)" ] ; then \
			echo "\tinstalling exa" ; \
			brew install exa ; \
		fi; \
	fi;

	@if [ -x "$$(command -v brew)" ] ; then \
		if [ ! -x "$$(command -v fzf)" ] ; then \
			echo "\tinstalling fzf" ; \
			brew install fzf ; \
		fi; \
	fi;

	@if [ ! -d ~/.oh-my-git ] ; then \
		echo "\tinstalling oh-my-git" ; \
		git clone https://github.com/arialdomartini/oh-my-git.git ~/.oh-my-git ; \
	fi;

	@@if [ ! -f ~/.vim/autoload/plug.vim ] ; then \
		echo "\tinstalling vim-plug" ; \
		curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim ; \
	fi;

.PHONY: test
test:
	@echo
	@echo '***** Testing Things *****'
	@echo

.PHONY: restore
restore:
	@echo
	@echo '***** Restoring dotfiles from timestamp $(RESTORE_TIMESTAMP) *****'
	@echo

	@if [ $(RESTORE_TIMESTAMP) == notarealbackupttimestamp ] ; then \
		echo "\tYou must supply a timestamp when trying to restore: make restore RESTORE_TIMESTAMP=<desired timestamp>" ; \
	elif [ -d ~/.dotfile_backups/$(RESTORE_TIMESTAMP) ] ; then \
		cp ~/.dotfile_backups/$(RESTORE_TIMESTAMP)/.* ~/ ; \
	else \
		echo "\tNo backups found for timestamp $(RESTORE_TIMESTAMP)" ; \
	fi;
