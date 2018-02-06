#!/bin/bash

FILELIST=(.bash_profile .bashrc .git-prompt.sh .gitconfig .gitignore .htoprc .perlcriticrc .perltidyrc .profile .screenrc .tmux.conf .vimrc)
MAKE_TIMESTAMP="$(date +%s)"
RESTORE_TIMESTAMP="${RESTORE_TIMESTAMP:-notarealbackuptimestamp}"

backup () {
  echo
  echo '***** Backing up current Dotfiles *****'
  echo

  if [ ! -d ~/.dotfile_backups ] ; then
    mkdir ~/.dotfile_backups
  fi

  if [ ! -d ~/.dotfile_backups/$MAKE_TIMESTAMP ] ; then
    mkdir ~/.dotfile_backups/$MAKE_TIMESTAMP
  fi

  for f in ${FILELIST[@]}
  do
    if [ -f ~/$f ] ; then
      printf "\tbacking up $f\n"
      cp ~/$f ~/.dotfile_backups/$MAKE_TIMESTAMP
    fi
  done
}

deps () {
  echo
  echo '***** Installing Dependencies *****'
  echo

  if [ -x "$(command -v brew)" ] ; then
    if [ ! -x "$(command -v exa)" ] ; then
      printf "\tinstalling exa\n"
      brew install exa
    fi

    if [ ! -x "$(command -v fzf)" ] ; then
      printf "\tinstalling fzf\n"
      brew install fzf
      $(brew --prefix)/opt/fzf/install
    fi

    if [ ! -x "$(command -v git-summary)" ] ; then
      printf "\tinstalling git-extras\n"
      brew install git-extras
    fi
  fi

  if [ ! -d ~/.oh-my-git ] ; then
    printf "\tinstalling oh-my-git\n"
    git clone https://github.com/arialdomartini/oh-my-git.git ~/.oh-my-git
  fi

  if [ -x "$(command -v npm)" ] ; then
    if [ ! -x "$(command -v gr)" ] ; then
      printf "\tinstalling gr\n"
      npm install -g git-run
    fi
  fi

  if [ ! -f ~/.vim/autoload/plug.vim ] ; then
    printf "\tinstalling vim-plug\n"
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi
}

generate_ssl_cert () {
  echo
  echo '***** Creating a self-signed SSL cert for local dev *****'
  echo

  if [ -x "$(command -v openssl)" ]; then \
    openssl genrsa -des3 -passout pass:x -out ssl.pass.key 2048 > /dev/null 2>&1
    openssl rsa -passin pass:x -in ssl.pass.key -out ssl.key > /dev/null 2>&1
    rm ssl.pass.key
    openssl req -new -key ssl.key -out ssl.csr -subj /C=XX/ST=Some\ Place/L=Some\ Town/O=Some\ Org/OU=Some\ Group/CN=$(hostname) > /dev/null 2>&1
    openssl x509 -req -sha256 -days 365 -in ssl.csr -signkey ssl.key -out ssl.crt > /dev/null 2>&1
    rm ssl.csr
    mv ssl.key ~/
    mv ssl.crt ~/
    echo
    printf "\tssl.cert and ssl.key created in home folder\n"
    echo
  else
    printf "\topenssl is not installed\n"
  fi
}

install_bin () {
  echo
  echo '***** Installing extra bin files in ~/bin *****'
  echo

  if [ ! -d ~/bin ] ; then
    mkdir ~/bin
  fi

  cp ./bin/* ~/bin
}

install_dotfiles () {
  echo
  echo '***** Installing new Dotfiles *****'
  echo

  for f in ${FILELIST[@]}
  do
    printf "\tinstalling $f\n"
    cp ./$f ~/
  done
}

install_fonts () {
  echo
  echo '***** Installing new Fonts *****'
  echo

  if [ $(uname -s) = Darwin ] ; then
    printf "\tCopying new fonts to ~/Library/Fonts\n"
    cp ./fonts/* ~/Library/Fonts
  else
    if [ ! -d ~/.fonts ] ; then
      mkdir ~/.fonts
    fi

    printf "\tCopying new fonts to ~/.fonts\n"
    cp ./fonts/* ~/.fonts
  fi;
}

restore () {
  if [ $RESTORE_TIMESTAMP = notarealbackuptimestamp ] ; then
    echo
    printf "You must supply a timestamp when trying to restore: RESTORE_TIMESTAMP=<desired timestamp> install.sh\n"
    echo
  elif [ -d ~/.dotfile_backups/$RESTORE_TIMESTAMP ] ; then
    echo
    echo "***** Restoring dotfiles from timestamp '$RESTORE_TIMESTAMP' *****"
    echo

    cp ~/.dotfile_backups/$RESTORE_TIMESTAMP/.* ~/ 2>/dev/null
  else
    printf "\tNo backups found for timestamp $RESTORE_TIMESTAMP\n"
  fi
}

setup_git () {
  echo
  echo '***** Setting up git user information *****'
  echo

  echo "Enter the name for your git commits, followed by [ENTER]:"
  read GIT_NAME

  echo

  echo "Enter the email address for your git commits, followed by [ENTER]:"
  read GIT_EMAIL

  echo "[user]
  name = $GIT_NAME
  email = $GIT_EMAIL
  " > ~/.gitconfig_custom
}

install () {
  backup
  deps
  generate_ssl_cert
  setup_git
  install_dotfiles
  install_fonts
}

help () {
  printf "\nsetup.sh - installs some dotfiles, fonts and useful applications for terminal environment\n\n"
  echo "Commands:"
  printf "\tbackup - will backup current dotfiles to '~/.dotfile_backups/<current timestamp>'\n"
  printf "\tdeps - will try to install dependencies\n"
  printf "\tgenerate_ssl_cert - will generate a self-signed ssl cert and copy the files to your home folder\n"
  printf "\tinstall - runs the 'backup', 'deps' 'generate_ssl_cert' 'install_dotfiles', 'install_fonts' and 'setup_git' targets -- this is the default command\n"
  printf "\tinstall_bin - will install new binaries to '~/bin'; '~/bin' is already added to the path in the included .bashrc\n"
  printf "\tinstall_dotfiles - will install the new dotfiles to '~/'\n"
  printf "\tinstall_fonts - will install new fonts to '~/Library/Fonts' or '~/.fonts' on other systems\n"
  printf "\tinstall_restore - will restore backed up dotfiles, usage 'RESTORE_TIMESTAMP=<desired timestamp> ./setup.sh restore'\n"
  printf "\tsetup_git - asks you to enter a name and email used when making commits with git\n"
  echo
  echo "Note: the default command is 'install', it runs the 'backup', 'deps', 'generate_ssl_cert', 'install_dotfiles', and 'install_fonts' commands"
  echo
}

COMMAND_RUN=0

for key in "$@"
do
case $key in
  backup)
    backup
    COMMAND_RUN=1
    break
    ;;
  deps)
    deps
    COMMAND_RUN=1
    break
    ;;
  generate_ssl_cert)
    generate_ssl_cert
    COMMAND_RUN=1
    break
    ;;
  install)
    install
    COMMAND_RUN=1
    break
    ;;
  install_bin)
    install_bin
    COMMAND_RUN=1
    break
    ;;
  install_dotfiles)
    install_dotfiles
    COMMAND_RUN=1
    break
    ;;
  install_fonts)
    install_fonts
    COMMAND_RUN=1
    break
    ;;
  restore)
    restore
    COMMAND_RUN=1
    break
    ;;
  setup_git)
    setup_git
    COMMAND_RUN=1
    break
    ;;
  *)
    help
    exit
    ;;
esac
done

if [ $COMMAND_RUN = 0 ] ; then
  install
fi

echo
