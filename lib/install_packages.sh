# shellcheck shell=bash

load_package_file() {
  local package_file="$1"
  local package_line

  PACKAGE_LIST=()

  if [ ! -f "$package_file" ]; then
    printf "Missing package manifest: %s\n" "$package_file" >&2
    exit 1
  fi

  while IFS= read -r package_line || [ -n "$package_line" ]; do
    case "$package_line" in
    '' | \#*)
      continue
      ;;
    *)
      PACKAGE_LIST+=("$package_line")
      ;;
    esac
  done <"$package_file"
}

apt_install_if_available() {
  local package_name="$1"

  if apt-cache show "$package_name" >/dev/null 2>&1; then
    printf "\tinstalling optional apt dependency %s\n" "$package_name"
    sudo apt install -y "$package_name"
  else
    printf "\tskipping optional apt dependency %s (package not available)\n" "$package_name"
  fi
}

brew_install_package() {
  local package_name="$1"

  case "$package_name" in
  cask:*)
    package_name="${package_name#cask:}"
    printf "\tinstalling %s (cask)\n" "$package_name"
    brew install --cask "$package_name"
    ;;
  *)
    printf "\tinstalling %s\n" "$package_name"
    brew install "$package_name"
    ;;
  esac
}

optional_manifest_dir() {
  if [ "$OS" = Darwin ]; then
    printf "%s\n" "$SCRIPT_DIR/packages/optional/homebrew"
  else
    printf "%s\n" "$SCRIPT_DIR/packages/optional/apt"
  fi
}

list_optional_groups() {
  local manifest_dir manifest_file

  manifest_dir="$(optional_manifest_dir)"

  for manifest_file in "$manifest_dir"/*.txt; do
    [ -f "$manifest_file" ] || continue
    basename "$manifest_file" .txt
  done
}

install_optional_groups() {
  local group_name manifest_path dep

  [ "$#" -gt 0 ] || return 0

  echo
  echo '***** Installing Optional Package Groups *****'
  echo

  for group_name in "$@"; do
    manifest_path="$(optional_manifest_dir)/$group_name.txt"

    if [ ! -f "$manifest_path" ]; then
      printf "Unknown optional package group: %s\n" "$group_name" >&2
      printf "Available groups for %s:\n" "$OS" >&2
      list_optional_groups >&2
      exit 1
    fi

    printf "\tgroup: %s\n" "$group_name"
    load_package_file "$manifest_path"

    if [ "$OS" = Darwin ]; then
      if [ ! -x "$(command -v brew)" ]; then
        printf "\tSkipping %s because Homebrew is not available\n" "$group_name"
        continue
      fi

      for dep in "${PACKAGE_LIST[@]}"; do
        brew_install_package "$dep"
      done
    elif [ -x "$(command -v apt)" ]; then
      for dep in "${PACKAGE_LIST[@]}"; do
        apt_install_if_available "$dep"
      done
    else
      printf "\tSkipping %s because no supported package manager was detected\n" "$group_name"
    fi
  done
}

deps() {
  echo
  echo '***** Installing Dependencies *****'
  echo

  if [ "$OS" = Darwin ]; then
    load_package_file "$SCRIPT_DIR/packages/homebrew.txt"

    if [ ! -x "$(command -v brew)" ]; then
      NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      if [ -x "$(command -v brew)" ]; then
        eval "$(brew shellenv)"
      fi
    fi

    if [ -x "$(command -v brew)" ]; then
      for dep in "${PACKAGE_LIST[@]}"; do
        brew_install_package "$dep"
      done

      if [ "$FORCE_UPGRADE" = 1 ] || [ ! -f /usr/local/bin/ctags ]; then
        printf "\tinstalling ctags from homebrew\n"
        brew install --HEAD universal-ctags/universal-ctags/universal-ctags
      fi

      if [ -x "$(command -v fzf)" ]; then
        printf "\tinstalling fzf bindings and fuzzy completion\n"
        "$(brew --prefix)/opt/fzf/install" --all
      fi
    fi

    printf "\tinstalling Volta nodejs tools and some global npm packages\n"
    curl https://get.volta.sh | bash
    VOLTA_HOME="$HOME/.volta"
    PATH="$VOLTA_HOME/bin:$PATH"
    volta install node
    load_package_file "$SCRIPT_DIR/packages/npm-global.txt"
    npm install --global "${PACKAGE_LIST[@]}"
  else
    load_package_file "$SCRIPT_DIR/packages/apt.txt"

    if [ -x "$(command -v apt)" ]; then
      printf "\tinstalling apt dependencies\n"
      sudo apt update
      sudo apt install -y "${PACKAGE_LIST[@]}"
      apt_install_if_available fastfetch
      apt_install_if_available git-delta
      apt_install_if_available starship
    fi

    if [ "$FORCE_UPGRADE" = 1 ] || [ ! -x "$(command -v fzf)" ]; then
      printf "\tinstalling fzf\n"
      if [ -d ~/.fzf ]; then
        cd ~/.fzf || exit
        git pull
        cd - || exit
      else
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
      fi
      ~/.fzf/install --all
    fi

    # TODO: setup azure-cli, fd, scc
  fi

  install_optional_groups "$@"

  if [ "$FORCE_UPGRADE" = 1 ] || [ ! -d ~/.oh-my-zsh ]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi

  if [ "$FORCE_UPGRADE" = 1 ] || [ ! -f ~/.vim/autoload/plug.vim ] || [ ! -f ~/.local/share/nvim/site/autoload/plug.vim ]; then
    printf "\tinstalling vim-plug for vim and neovim\n"
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi
}
