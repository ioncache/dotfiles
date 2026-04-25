# shellcheck shell=bash

install_dotfile_path() {
  local source_path="$1"
  local target_path="$HOME/${source_path#$DOTFILES_DIR/}"
  local remove_legacy_nvim_init=0

  printf "\tinstalling %s" "$source_path"

  if [ "$source_path" = "$DOTFILES_DIR/.shell_secrets" ] && [ -f "$HOME/.shell_secrets" ]; then
    printf ": already exists, skipping\n"
    return 0
  fi

  if [ "$source_path" = "$DOTFILES_DIR/.config" ] && [ -f "$HOME/.config/nvim/init.lua" ]; then
    mkdir -p "$target_path"

    if [ -f "$HOME/.config/nvim/init.vim" ] && cmp -s "$HOME/.config/nvim/init.vim" "$DOTFILES_DIR/.config/nvim/init.vim"; then
      remove_legacy_nvim_init=1
    fi

    tar -C "$source_path" --exclude='./nvim/init.vim' -cf - . | tar -C "$target_path" -xf -

    if [ "$remove_legacy_nvim_init" -eq 1 ]; then
      rm -f "$HOME/.config/nvim/init.vim"
      printf ": kept existing ~/.config/nvim/init.lua and removed repo init.vim shim\n"
    else
      printf ": kept existing ~/.config/nvim/init.lua and skipped repo init.vim shim\n"
    fi

    return 0
  fi

  cp -R "$source_path" "$HOME/"
  printf "\n"
}

backup() {
  local dotfile
  local file_path

  echo
  echo '***** Backing up current Dotfiles *****'
  echo

  if [ ! -d "$HOME/.dotfile_backups" ]; then
    mkdir "$HOME/.dotfile_backups"
  fi

  if [ ! -d "$HOME/.dotfile_backups/$MAKE_TIMESTAMP" ]; then
    mkdir "$HOME/.dotfile_backups/$MAKE_TIMESTAMP"
  fi

  for file_path in "$DOTFILES_DIR"/.[a-z]*; do
    dotfile=${file_path#"$DOTFILES_DIR/"}

    if [ -e "$HOME/$dotfile" ]; then
      printf "\tbacking up %s\n" "$dotfile"
      cp -R "$HOME/$dotfile" "$HOME/.dotfile_backups/$MAKE_TIMESTAMP"
    fi
  done
}

dotfiles() {
  local file_path

  echo
  echo '***** Installing new Dotfiles *****'
  echo

  for file_path in "$DOTFILES_DIR"/.[a-z]*; do
    install_dotfile_path "$file_path"
  done
}

restore() {
  local file_path

  if [ "$RESTORE_TIMESTAMP" = notarealbackuptimestamp ]; then
    echo
    printf "You must supply a timestamp when trying to restore: RESTORE_TIMESTAMP=<desired timestamp> install.sh\n"
    echo
  elif [ -d "$HOME/.dotfile_backups/$RESTORE_TIMESTAMP" ]; then
    echo
    echo "***** Restoring dotfiles from timestamp '$RESTORE_TIMESTAMP' *****"
    echo

    for file_path in "$HOME/.dotfile_backups/$RESTORE_TIMESTAMP"/.[!.]* "$HOME/.dotfile_backups/$RESTORE_TIMESTAMP"/..?*; do
      [ -e "$file_path" ] || continue
      cp -R "$file_path" "$HOME/"
    done
  else
    printf "\tNo backups found for timestamp %s\n" "$RESTORE_TIMESTAMP"
  fi
}
