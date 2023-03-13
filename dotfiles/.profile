# loads the correct shell config

if [ -n "$BASH_VERSION" ]; then
  # include .bashrc if it exists
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
elif [ -n "$ZSH_VERSION" ]; then
  # include .zshrc if it exists
  if [ -f "$HOME/.zshrc" ]; then
    . "$HOME/.zshrc"
  fi
fi
