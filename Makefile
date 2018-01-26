########################################################################
# ioncache Dotfile Makefile
########################################################################

# why on earth did I do this as a Makefile? I hate Makefiles.

OS                 = $(shell uname -s)
FILELIST           = .bash_profile .bashrc .git-prompt.sh .gitconfig .gitignore .htoprc .perlcriticrc .perltidyrc .profile .screenrc .tmux.conf .vimrc
MAKE_TIMESTAMP     = $(shell date +%s)``
RESTORE_TIMESTAMP ?= "notarealbackuptimestamp"
HOSTNAME           = $(shell hostname)

##### Default actions when running make -- makes the base api package
.PHONY: main
main: backup deps generate_ssl_cert install

.PHONY: install
# install: install_dotfiles install_fonts install_bin
install: install_dotfiles install_fonts

.PHONY: install_dotfiles
install_dotfiles:
	@echo
	@echo '***** Installing new Dotfiles *****'
	@echo

	@for f in $(FILELIST) ; \
	do \
		echo "\tinstalling $$f" ; \
		cp ./$$f ~/ ; \
	done ;

.PHONY: install_fonts
install_fonts:
	@echo
	@echo '***** Installing new Fonts *****'
	@echo

	@if [ $(OS) = Darwin ] ; then \
		cp ./fonts/* ~/Library/Fonts ; \
	else \
		if [ ! -d ~/.fonts ] ; then \
			mkdir ~/.fonts ; \
		fi; \
		cp ./fonts/* ~/.fonts ; \
	fi;

.PHONY: install_bin
install_bin:
	@echo
	@echo '***** Installing extra bin files in ~/bin *****'
	@echo

	@if [ ! -d ~/bin ] ; then \
		mkdir ~/bin ; \
	fi;

	@cp ./bin/* ~/bin

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

.PHONY: generate_ssl_cert
generate_ssl_cert:
	@echo
	@echo '***** Creating a self-signed SSL cert for local dev *****'
	@echo

	@if [ -x "$$(command -v openssl)" ]; then \
		openssl genrsa -des3 -passout pass:x -out ssl.pass.key 2048 ; \
		openssl rsa -passin pass:x -in ssl.pass.key -out ssl.key ; \
		rm ssl.pass.key ; \
		openssl req -new -key ssl.key -out ssl.csr -subj /C=XX/ST=Some\ Place/L=Some\ Town/O=Some\ Org/OU=Some\ Group/CN=$(HOSTNAME) ; \
		openssl x509 -req -sha256 -days 365 -in ssl.csr -signkey ssl.key -out ssl.crt ; \
		rm ssl.csr ; \
		mv ssl.key ~/ ; \
		mv ssl.crt ~/ ; \
		echo ; \
		echo "\tssl.cert and ssl.key created in home folder" ; \
		echo ; \
	else \
		echo "\topenssl is not installed" ; \
	fi;

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
		if [ ! -x "$$(command -v fzf)" ] ; then \
			echo "\tinstalling fzf" ; \
			brew install fzf ; \
			$$(brew --prefix)/opt/fzf/install ; \
		fi; \
		if [ ! -x "$$(command -v git-summary)" ] ; then \
			echo "\tinstalling git-extras" ; \
			brew install git-extras ; \
		fi; \
	fi;

	@if [ ! -d ~/.oh-my-git ] ; then \
		echo "\tinstalling oh-my-git" ; \
		git clone https://github.com/arialdomartini/oh-my-git.git ~/.oh-my-git ; \
	fi;

	@if [ -x "$$(command -v npm)" ] ; then \
		if [ ! -x "$$(command -v gr)" ] ; then \
			echo "\tinstalling gr" ; \
			npm install -g git-run ; \
		fi; \
	fi;

	@if [ ! -f ~/.vim/autoload/plug.vim ] ; then \
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

	@if [ $(RESTORE_TIMESTAMP) = notarealbackuptimestamp ] ; then \
		echo "\tYou must supply a timestamp when trying to restore: make restore RESTORE_TIMESTAMP=<desired timestamp>" ; \
	elif [ -d ~/.dotfile_backups/$(RESTORE_TIMESTAMP) ] ; then \
		cp ~/.dotfile_backups/$(RESTORE_TIMESTAMP)/.* ~/ 2>/dev/null; \
	else \
		echo "\tNo backups found for timestamp $(RESTORE_TIMESTAMP)" ; \
	fi;
