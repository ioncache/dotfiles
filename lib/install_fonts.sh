# shellcheck shell=bash

fonts() {
  echo
  echo '***** Installing new Fonts *****'
  echo

  if [ "$OS" = Darwin ]; then
    printf "\tCopying new fonts to ~/Library/Fonts\n"
    cp "$FONTS_DIR"/* "$HOME/Library/Fonts"
  else
    if [ ! -d "$HOME/.local/share/fonts" ]; then
      mkdir -p "$HOME/.local/share/fonts"
    fi

    printf "\tCopying new fonts to ~/.local/share/fonts\n"
    cp "$FONTS_DIR"/* "$HOME/.local/share/fonts"

    if [ -x "$(command -v fc-cache)" ]; then
      printf "\tRefreshing font cache\n"
      fc-cache -f "$HOME/.local/share/fonts"
    fi
  fi
}
