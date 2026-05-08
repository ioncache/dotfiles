# shellcheck shell=bash

bin_scripts() {
  echo
  echo '***** Installing bin scripts *****'
  echo

  if [ ! -d "$HOME/bin" ]; then
    mkdir -p "$HOME/bin"
  fi

  for file_path in "$BIN_DIR"/*; do
    [ -f "$file_path" ] || continue
    printf "\tinstalling %s\n" "$file_path"
    cp "$file_path" "$HOME/bin/"
    chmod +x "$HOME/bin/$(basename "$file_path")"
  done
}
