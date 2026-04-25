# base .zshrc

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

if [ -x "$(command -v brew)" ]; then
  BREW_ZSH_COMPLETIONS="$(brew --prefix)/share/zsh/site-functions"
  if [ -d "$BREW_ZSH_COMPLETIONS" ]; then
    fpath=("$BREW_ZSH_COMPLETIONS" $fpath)
  fi
fi

source "$HOME/.ohmyzshrc"
source "$HOME/.shell_common"

autoload -Uz compinit
compinit -i

if [ -f "$HOME"/.zsh_aliases ]; then
  source "$HOME"/.zsh_aliases
fi

if [ -f /etc/zsh ] && ! setopt -oq posix; then
  source /etc/zsh
fi

export HISTSIZE=100000
export SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_SPACE

# NOTE: leave this as the last section of this file so things in .shell_secrets can override anything else in this file
# store any access keys, credentials, etc. in $HOME/.shell_secrets
# can also be used to setup other custom things, like extra additions to $PATH or custom aliases
if [ -f "$HOME"/.shell_secrets ]; then
  source "$HOME"/.shell_secrets
fi
