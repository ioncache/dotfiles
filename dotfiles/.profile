# shellcheck shell=sh

if [ "$(uname -s)" = Darwin ] && [ -d /opt/homebrew/bin ]; then
  PATH="/opt/homebrew/bin:$PATH"
fi
if [ -d "$HOME/.local/bin" ]; then
  PATH="$HOME/.local/bin:$PATH"
fi
export PATH

if command -v mise >/dev/null 2>&1; then
  if [ -n "$BASH_VERSION" ]; then
    eval "$(mise activate bash --shims)"
  elif [ -n "$ZSH_VERSION" ]; then
    eval "$(mise activate zsh --shims)"
  fi
fi

if [ -n "$BASH_VERSION" ]; then
  # include .bashrc if it exists
  if [ -f "$HOME/.bashrc" ]; then
    # shellcheck disable=SC1090,SC1091
    . "$HOME/.bashrc"
  fi
fi
