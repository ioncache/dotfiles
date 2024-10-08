# base .zshrc

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

source $HOME/.ohmyzshrc

#########################
# Everything else config #
#########################

# cache OS name for some conditionals
OS=$(uname -s)

# enable Homebrew
if [ "$OS" = Darwin ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"

  export ZPLUG_HOME=$(brew --prefix)/opt/zplug
  source $ZPLUG_HOME/init.zsh

  # autojump
  [ -f $(brew --prefix)/etc/profile.d/autojump.sh ] && . $(brew --prefix)/etc/profile.d/autojump.sh

  # brew shell completion
  if [ -d "$(brew --prefix)"/etc/bash_completion.d ]; then
    for FILE in $(brew --prefix)/etc/bash_completion.d; do
      source "$FILE"
    done
  fi
fi

if [ -d "/usr/sbin" ]; then
  PATH="/usr/sbin:$PATH"
fi

if [ -d "/usr/local/sbin" ]; then
  PATH="/usr/local/sbin:$PATH"
fi

if [ -d "/sbin" ]; then
  PATH="/sbin:$PATH"
fi

if [ -d "/usr/local/opt/gnu-tar/libexec/gnubin" ]; then
  PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
fi

if [ -d "/usr/local/bin" ]; then
  PATH="/usr/local/bin:$PATH"
fi

if [ -d "$HOME/bin" ]; then
  PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.cargo/bin" ]; then
  PATH="$HOME/.cargo/bin:$PATH"
fi

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# uncomment for a colored prompt, if the terminal has the capability
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    unset color_prompt
  fi
fi

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

if [ "$color_prompt" = yes ]; then
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]\$ '
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\W\$ '
fi

unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt*)
  PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
  ;;
*) ;;
esac

# Starship is a cross-platform command prompt
if [ -x "$(command -v starship)" ]; then
  eval "$(starship init zsh)"
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r "$HOME"/.dircolors && eval "$(dircolors -b "$HOME"/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias grep='grep --color=always'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# setup iterm2 stuff if it exists
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

#####################
# alias definitions #
#####################

if [ -f "$HOME"/.zsh ]; then
  source "$HOME"/.zsh_aliases
fi

if [ -f /etc/zsh ] && ! setopt -oq posix; then
  source /etc/zsh
fi

# 'ls' related aliases
if which exa >/dev/null; then
  # exa is a `ls` replacement
  alias ls='exa'
  alias l='ls -F'
  alias la='ls -a'
  alias ll='ls --header --long --all --group-directories-first --git'
else
  alias l='ls -CF'
  alias la='ls -A'
  alias ll='ls -alhF --color --group-directories-first'
fi

if which bat >/dev/null; then
  alias cat='bat -p --paging=never'
fi

# some OS specific aliases/options
case $OS in
Darwin)
  if ! which exa >/dev/null; then
    alias ll='ls -alhFG'
  fi

  alias updatedb='sudo /usr/libexec/locate.updatedb'
  ;;

SunOS)
  alias top='prstat -s cpu -a -n 8 '
  if [ -f /usr/ucb/ps ]; then
    alias ps='/usr/ucb/ps'
  fi
  ;;
esac

# code editor aliases for betas

if which code-insiders >/dev/null; then
  alias code=code-insiders
fi

if which direnv >/dev/null; then
  eval "$(direnv hook zsh)"
fi

# fzf is a fuzzy finder
[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh

# non-stystem node
if [ -d "$HOME/.volta" ]; then
  export VOLTA_HOME="$HOME/.volta"
  export PATH="$VOLTA_HOME/bin:$PATH"
elif [ -d "$HOME/.nodenv/shims" ]; then
  export PATH="$HOME/.nodenv/shims:$PATH"
  eval "$(nodenv init -)"
elif [ -d "$HOME"/n ]; then
  export N_PREFIX="$HOME/n"
  [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"
elif [ -d "$HOME/.nenv/bin" ]; then
  export PATH="$HOME/.nenv/bin:$PATH"
  eval "$(nenv init -)"
fi

# add npm completion
if which npm >/dev/null; then
  source <(npm completion)
fi

#########################
# environment variables #
#########################
# NOTE: override in .shell_secrets if desired

export EDITOR=vim # emacs is a cruel punishment on humanity
export PAGER=less
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
