# shellcheck shell=sh

# loads the correct shell config

if [ -n "$BASH_VERSION" ]; then
  # include .bashrc if it exists
  if [ -f "$HOME/.bashrc" ]; then
    # shellcheck disable=SC1090,SC1091
    . "$HOME/.bashrc"
  fi
elif [ -n "$ZSH_VERSION" ]; then
  # include .zshrc if it exists
  if [ -f "$HOME/.zshrc" ]; then
    # shellcheck disable=SC1090,SC1091
    . "$HOME/.zshrc"
  fi
fi
