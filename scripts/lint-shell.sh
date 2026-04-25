#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -eq 0 ]; then
  exit 0
fi

sh_files=()
bash_files=()
zsh_files=()

for file_path in "$@"; do
  case "$file_path" in
  dotfiles/.zshrc | dotfiles/.ohmyzshrc)
    zsh_files+=("$file_path")
    ;;
  dotfiles/.profile)
    sh_files+=("$file_path")
    ;;
  *)
    bash_files+=("$file_path")
    ;;
  esac
done

if [ "${#sh_files[@]}" -gt 0 ]; then
  ./node_modules/.bin/shellcheck "${sh_files[@]}"
fi

if [ "${#bash_files[@]}" -gt 0 ]; then
  ./node_modules/.bin/shellcheck --shell=bash "${bash_files[@]}"
fi

if [ "${#zsh_files[@]}" -gt 0 ]; then
  zsh -n "${zsh_files[@]}"
fi