# ioncache .bashrc

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

if [ -d "$HOME/bin/arcanist/bin" ] ; then
    PATH="$HOME/bin/arcanist/bin:$PATH"
fi

if [ -d /var/lib/gems/1.8/bin/ ] ; then
    PATH="/var/lib/gems/1.8/bin/:$PATH"
fi

if [ -d "/opt/csw/bin" ] ; then
    PATH="/opt/csw/bin:$PATH"
fi

if [ -d "/usr/local/bin" ] ; then
    PATH="/usr/local/bin:$PATH"
fi

if [ -d "/usr/local/opt/gnu-tar/libexec/gnubin" ] ; then
    PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
fi

#if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
#export PYENV_ROOT=/usr/local/opt/pyenv

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ -f ~/.git-prompt.sh ] ; then
    source ~/.git-prompt.sh
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]$(__git_ps1 " (%s)")\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\W$(__git_ps1 " (%s)")\$ '
    #PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

if [ -f ~/.oh-my-git/prompt.sh ] ; then
    source ~/.oh-my-git/prompt.sh
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
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=always'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=1000
export HISTFILESIZE=2000

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups:erasedups
# ... and ignore same sucessive entries.
export HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

export EDITOR=vim
export PAGER=less

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"


# Alias definitions.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# cache OS name for some conditionals
OS=$(uname -s)

# custom aliases
alias la='ls -A'
alias l='ls -CF'
alias prereqs='find -name '\''*pl'\'' -o -name '\''*pm'\'' | xargs scan_prereqs | perl -ne '\''next if /^\*/; s/\s+=.*$//; print'\'' | sort | uniq'

if which exa > /dev/null; then
  alias ls='exa'
  alias ll='ls -alhF --group-directories-first'
else
  alias ll='ls -alhF --color --group-directories-first'
fi

# some OSX vs. linux aliases/options
if [ "$OS" == "Darwin" ]; then
    if ! which exa > /dev/null; then
      alias ll='ls -alhFG'
    fi

    alias updatedb='sudo /usr/libexec/locate.updatedb'
elif [ "$OS" == "SunOS" ] ; then
    alias top='prstat -s cpu -a -n 8 '
    if [ -f /usr/ucb/ps ] ; then
      alias ps='/usr/ucb/ps'
    fi
fi

# enable ack if installed from the ack-grep package
if command -v ack-grep >/dev/null 2>&1 ; then
    alias ack='ack-grep'
fi

# setup perlbrew
if [ -d "$HOME/perl5/perlbrew" ] && [ ! "$OS" == "SunOS" ] ; then
    source ~/perl5/perlbrew/etc/bashrc
fi

# brew bash completion
if [ -f /usr/local/etc/bash_completion.d ]; then
    source /usr/local/etc/bash_completion.d
fi

if [ -f ~/.git-prompt.sh ]; then
    source ~/.git-prompt.sh
fi

if [ -d  /usr/local/lib/node_modules ] ; then
    export NODE_PATH='/usr/local/lib/node_modules'
fi

# store any access keys, credentials, etc. in ~/.bash_secrets
if [ -f ~/.bash_secrets ] ; then
  source ~/.bash_secrets
fi

alias apm=apm-beta
alias atom=atom-beta

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
