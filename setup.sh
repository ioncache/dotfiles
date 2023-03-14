#!/bin/bash

FORCE_UPGRADE="${FORCE_UPGRADE:-0}"
MAKE_TIMESTAMP="$(date +%s)"
OS="$(uname -s)"
RESTORE_TIMESTAMP="${RESTORE_TIMESTAMP:-notarealbackuptimestamp}"

backup() {
  echo
  echo '***** Backing up current Dotfiles *****'
  echo

  if [ ! -d "$HOME/.dotfile_backups" ]; then
    mkdir "$HOME/.dotfile_backups"
  fi

  if [ ! -d "$HOME"/.dotfile_backups/"$MAKE_TIMESTAMP" ]; then
    mkdir "$HOME"/.dotfile_backups/"$MAKE_TIMESTAMP"
  fi

  for f in ./dotfiles/.[a-z]*; do
    dotfile=${f#"./dotfiles/"}

    if [ -f "$HOME/$dotfile" ]; then
      printf "\tbacking up %s\n" "$dotfile"
      cp "$HOME"/"$dotfile" "$HOME"/.dotfile_backups/"$MAKE_TIMESTAMP"
    fi
  done
}

HOMEBREW_DEPS=(azure-cli autojump bat diff-so-fancy direnv exa fd fzf git git-extras htop jq ripgrep scc starship thefuck tldr vim wget)

deps() {
  echo
  echo '***** Installing Dependencies *****'
  echo

  if [ "$OS" = Darwin ]; then
    # install homebrew if not already installed -- the installation will pause and allow for cancelling if desired
    if [ ! -x "$(command -v brew)" ]; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    if [ -x "$(command -v brew)" ]; then

      for dep in "${HOMEBREW_DEPS[@]}"; do
        printf "\tinstalling %s\n" "$dep"
        brew install "$dep"
      done

      if [ "$FORCE_UPGRADE" = 1 ] || [ ! -f /usr/local/bin/ctags ]; then
        printf "\tinstalling ctags from homebrew\n"
        brew install --HEAD universal-ctags/universal-ctags/universal-ctags
      fi

      if [ -x "$(command -v fzf)" ]; then
        printf "\tinstalling fzf bindings and fuzzy completion\n"
        "$(brew --prefix)/opt/fzf/install"
      fi
    fi

    # install Volta nodejs tools and some global npm packages
    printf "\tinstalling Volta nodejs tools and some global npm packages\n"
    curl https://get.volta.sh | bash
    VOLTA_HOME="$HOME"/.volta
    PATH="$VOLTA_HOME/bin:$PATH"
    volta install node
    npm install --global ncu snyk

  else
    if [ -x "$(command -v cargo)" ]; then
      if [ "$FORCE_UPGRADE" = 1 ] || ([ -x "$(command -v cmake)" ] && [ ! -x "$(command -v exa)" ]); then
        # TODO: install make, cmake and cargo if required
        printf "\tinstalling exa (this requires sudo)\n"
        git clone https://github.com/ogham/exa.git
        cd exa || exit
        sudo make install
        cd ..
        rm -rf exa
      fi

      if [ "$FORCE_UPGRADE" = 1 ] || [ ! -x "$(command -v starship)" ]; then
        printf "\tinstalling starship\n"
        cargo install starship
      fi
    fi

    if [ "$FORCE_UPGRADE" = 1 ] || [ ! -x "$(command -v fzf)" ]; then
      printf "\tinstalling fzf\n"
      printf "\tanswer y, n, during install\n"
      if [ -d ~/.fzf ]; then
        cd ~/.fzf || exit
        git pull
        cd - || exit
      else
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
      fi
      ~/.fzf/install
    fi

    if [ "$FORCE_UPGRADE" = 1 ] || [ ! -x "$(command -v git-summary)" ]; then
      printf "\tinstalling git-extras (this requires sudo)\n"
      sudo apt-get install git-extras
    fi

    if [ "$FORCE_UPGRADE" = 1 ] || [ ! -x "$(command -v j)" ]; then
      printf "\tinstalling autojump\n"
      sudo apt-get install autojump
    fi

    if [ "$FORCE_UPGRADE" = 1 ] || [ ! -x "$(command -v jq)" ]; then
      printf "\tinstalling jq\n"
      sudo apt-get install jq
    fi

    if [ "$FORCE_UPGRADE" = 1 ] || [ ! -x "$(command -v bat)" ]; then
      printf "\tinstalling bat\n"
      printf "\tTODO: install this for linux\n"
    fi

    if [ "$FORCE_UPGRADE" = 1 ] || [ ! -x "$(command -v fd)" ]; then
      printf "\tinstalling fd\n"
      printf "\tTODO: install this for linux\n"
    fi
  fi

  if [ "$FORCE_UPGRADE" = 1 ] || [ ! -f ~/.vim/autoload/plug.vim ]; then
    printf "\tinstalling vim-plug\n"
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi
}

dotfiles() {
  echo
  echo '***** Installing new Dotfiles *****'
  echo

  for f in ./dotfiles/.[a-z]*; do
    printf "\tinstalling %s" "$f"
    if [ "$f" == ".shell_secrets" ] && [ -f "$HOME/.shell_secrets" ]; then
      printf ": already exists, skipping"
    else
      cp ./"$f" "$HOME/"
    fi
    printf "\n"
  done
}

fonts() {
  echo
  echo '***** Installing new Fonts *****'
  echo

  if [ "$OS" = Darwin ]; then
    printf "\tCopying new fonts to ~/Library/Fonts\n"
    cp ./fonts/* "$HOME/Library/Fonts"
  else
    if [ ! -d "$HOME/.fonts" ]; then
      mkdir "$HOME"/.fonts
    fi

    printf "\tCopying new fonts to ~/.fonts\n"
    cp ./fonts/* "$HOME"/.fonts
  fi
}

restore() {
  if [ "$RESTORE_TIMESTAMP" = notarealbackuptimestamp ]; then
    echo
    printf "You must supply a timestamp when trying to restore: RESTORE_TIMESTAMP=<desired timestamp> install.sh\n"
    echo
  elif [ -d "$HOME"/.dotfile_backups/"$RESTORE_TIMESTAMP" ]; then
    echo
    echo "***** Restoring dotfiles from timestamp '$RESTORE_TIMESTAMP' *****"
    echo

    cp "$HOME"/.dotfile_backups/"$RESTORE_TIMESTAMP"/.* "$HOME"/ 2>/dev/null
  else
    printf "\tNo backups found for timestamp %s\n" "$RESTORE_TIMESTAMP"
  fi
}

setup_git() {
  echo
  echo '***** Setting up git user information *****'
  echo

  echo "Enter the name for your git commits, followed by [ENTER]:"
  read -r GIT_NAME

  echo

  echo "Enter the email address for your git commits, followed by [ENTER]:"
  read -r GIT_EMAIL

  echo "[user]
  name = $GIT_NAME
  email = $GIT_EMAIL
  " >"$HOME"/.gitconfig_custom
}

install() {
  backup
  deps
  setup_git
  dotfiles
  fonts
}

help() {
  printf "\nsetup.sh - installs some dotfiles, fonts and useful applications for terminal environments\n\n"
  echo "Commands:"

  printf "\n  Default:\n\n"
  printf "    install - runs the 'backup', 'deps' 'dotfiles', 'fonts' and 'setup_git' targets\n"

  printf "\n  Individual setup:\n\n"
  printf "    deps - will try to install dependencies\n"
  printf "    dotfiles - will install the new dotfiles to '~/'\n"
  printf "    fonts - will install new fonts to '~/Library/Fonts' or '~/.fonts' on other systems\n"

  printf "\n  Utility:\n\n"
  printf "    backup - will backup current dotfiles to '~/.dotfile_backups/<current timestamp>'\n"
  printf "    restore - will restore backed up dotfiles, usage 'RESTORE_TIMESTAMP=<desired timestamp> ./setup.sh restore'\n"
  printf "    setup_git - asks you to enter a name and email used when making commits with git\n"

  printf "\n  Flags:\n\n"
  printf "    --help - prints this help information (actually any unknown command will print the help)\n"
  echo
}

COMMAND_RUN=0

for key in "$@"; do
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
  install)
    install
    COMMAND_RUN=1
    break
    ;;
  dotfiles)
    dotfiles
    COMMAND_RUN=1
    break
    ;;
  fonts)
    fonts
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

if [ $COMMAND_RUN = 0 ]; then
  install
fi

echo
echo "NOTE: you will need to reload your \$SHELL config or open a new terminal for installation to take effect"
echo
