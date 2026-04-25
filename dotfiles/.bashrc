# base .bashrc

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

source "$HOME/.shell_common"

if [ "$OS" = Darwin ] && [ -x "$(command -v brew)" ]; then
  if [ -d "$(brew --prefix)"/etc/bash_completion.d ]; then
    for FILE in "$(brew --prefix)"/etc/bash_completion.d/*; do
      [ -f "$FILE" ] || continue
      source "$FILE"
    done
  fi
fi

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# append to the history file, don't overwrite it
shopt -s histappend

if [ -f "$HOME"/.bash_aliases ]; then
  source "$HOME"/.bash_aliases
fi

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
  source /etc/bash_completion
fi

# git-run bash completion
if which gr >/dev/null; then
  # NOTE: error when running the line below, using eval instead, yes it's evil
  # . <(gr completion)
  eval "$(gr completion)"
fi

if which npm >/dev/null; then
  source <(npm completion)
fi

export HISTSIZE=1000
export HISTFILESIZE=2000
export HISTCONTROL=ignoredups:erasedups # don't put duplicate lines in the history
export HISTCONTROL=ignoreboth           # ignore same sucessive entries

# NOTE: leave this as the last section of this file so things in .shell_secrets can override anything else in this file
# store any access keys, credentials, etc. in $HOME/.shell_secrets
# can also be used to setup other custom things, like extra additions to $PATH or custom aliases
if [ -f "$HOME"/.shell_secrets ]; then
  source "$HOME"/.shell_secrets
fi
