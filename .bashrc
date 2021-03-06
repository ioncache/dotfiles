# base .bashrc

# If not running interactively, don't do anything
[ -z "$PS1" ] && return


if [ -d "/usr/sbin" ] ; then
  PATH="/usr/sbin:$PATH"
fi

if [ -d "/usr/local/sbin" ] ; then
  PATH="/usr/local/sbin:$PATH"
fi

if [ -d "/sbin" ] ; then
  PATH="/sbin:$PATH"
fi

if [ -d "/usr/local/mysql/bin/" ] ; then
  PATH="/usr/local/mysql/bin/:$PATH"
fi

if [ -d "$HOME/bin" ] ; then
  PATH="$HOME/bin:$PATH"
fi

# arcanist is a CLI for use with Phabricator
if [ -d "$HOME/bin/arcanist/bin" ] ; then
  PATH="$HOME/bin/arcanist/bin:$PATH"
fi

if [ -d "/usr/local/bin" ] ; then
  PATH="/usr/local/bin:$PATH"
fi

if [ -d "/usr/local/opt/gnu-tar/libexec/gnubin" ] ; then
  PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
fi

if [ -d "$HOME/.cargo/bin" ] ; then
  PATH="$HOME/.cargo/bin:$PATH"
fi

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# uncomment for a colored prompt, if the terminal has the capability
force_color_prompt=yes

if [ -n "$force_color_prompt" ] ; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null ; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    unset color_prompt
  fi
fi

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ] ; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

if [ "$color_prompt" = yes ] ; then
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]\$ '
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\W\$ '
fi

if [ -x "$(command -v starship)" ] ; then
  eval "$(starship init bash)"
fi

unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ] ; then
  test -r $HOME/.dircolors && eval "$(dircolors -b $HOME/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias grep='grep --color=always'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# append to the history file, don't overwrite it
shopt -s histappend

# setup iterm2 stuff if it exists
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

#####################
# alias definitions #
#####################

if [ -f $HOME/.bash_aliases ] ; then
  source $HOME/.bash_aliases
fi

if [ -f /etc/bash_completion ] && ! shopt -oq posix ; then
  source /etc/bash_completion
fi

if [ -f $HOME/.git-completion.sh ] && ! shopt -oq posix ; then
  source $HOME/.git-completion.sh
elif [ -f /usr/local/etc/bash_completion.d/git-completion.bash ] && ! shopt -oq posix; then
  source /usr/local/etc/bash_completion.d/git-completion.bash
fi

# 'ls' related aliases
if which exa > /dev/null ; then
  alias ls='exa'
  alias l='ls -F'
  alias la='ls -a'
  alias ll='ls --header --long --all --group-directories-first --git'
else
  alias l='ls -CF'
  alias la='ls -A'
  alias ll='ls -alhF --color --group-directories-first'
fi

# cache OS name for some conditionals
OS=$(uname -s)

# some OS specific aliases/options
case $OS in
  Darwin)
    if ! which exa > /dev/null ; then
      alias ll='ls -alhFG'
    fi

    alias updatedb='sudo /usr/libexec/locate.updatedb'
    ;;

  SunOS)
    alias top='prstat -s cpu -a -n 8 '
    if [ -f /usr/ucb/ps ] ; then
      alias ps='/usr/ucb/ps'
    fi
    ;;
esac

# enable ack if installed from the ack-grep package
if command -v ack-grep >/dev/null 2>&1 ; then
  alias ack='ack-grep'
fi

# setup perlbrew -- you should really use perlbrew instead of your system perl, seriously
if [ -d "$HOME/perl5/perlbrew" ] && [ ! "$OS" == "SunOS" ] ; then
  source $HOME/perl5/perlbrew/etc/bashrc
fi

# brew bash completion
if [ -f /usr/local/etc/bash_completion.d ] ; then
  source /usr/local/etc/bash_completion.d
fi

# code editor aliases for betas

if which code-insiders > /dev/null ; then
  alias code=code-insiders
fi

if which atom-beta > /dev/null ; then
  alias apm=apm-beta
  alias atom=atom-beta
fi

if which direnv > /dev/null ; then
  eval "$(direnv hook bash)"
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# git-run bash completion
if which gr > /dev/null ; then
  # NOTE: error when running the line below, using eval instead, yes it's evil
  # . <(gr completion)
  eval "$(gr completion)"
fi

if [ -d $HOME/n ] ; then
  export N_PREFIX="$HOME/n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"
fi

# non-stystem node
if [ -d "$HOME/.nodenv/shims" ] ; then
  export PATH="$HOME/.nodenv/shims:$PATH"
  eval "$(nodenv init -)"
elif [ -d "$HOME/.nenv/bin" ] ; then
  export PATH="$HOME/.nenv/bin:$PATH"
  eval "$(nenv init -)"
fi

# add npm completion
#if which npm > /dev/null ; then
  #source <(npm completion)
  #eval "`npm completion`"
#fi

# autojump
if [ -f /usr/local/etc/profile.d/autojump.sh ] ; then
  . /usr/local/etc/profile.d/autojump.sh
elif [ -f /usr/share/autojump/autojump.sh ] ; then
  . /usr/share/autojump/autojump.sh
fi

#########################
# environment variables #
#########################
# NOTE: override in .bash_secrets if desired

export EDITOR=vim # emacs is a cruel punishment on humanity
export PAGER=less
export HISTSIZE=1000
export HISTFILESIZE=2000
export HISTCONTROL=ignoredups:erasedups # don't put duplicate lines in the history
export HISTCONTROL=ignoreboth # ignore same sucessive entries

# NOTE: leave this as the last section of this file so things in .bash_secrets can override anything else in this file
# store any access keys, credentials, etc. in $HOME/.bash_secrets
# can also be used to setup other custom things, like extra additions to $PATH or custom aliases
if [ -f $HOME/.bash_secrets ] ; then
  source $HOME/.bash_secrets
fi

