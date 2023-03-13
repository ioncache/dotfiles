# base .zshrc

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

###################
# Oh My Zsh config #
###################

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="dracula"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

#########################
# Everything else config #
#########################

# enable Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

if [ -d "/usr/sbin" ]; then
  PATH="/usr/sbin:$PATH"
fi

if [ -d "/usr/local/sbin" ]; then
  PATH="/usr/local/sbin:$PATH"
fi

if [ -d "/sbin" ]; then
  PATH="/sbin:$PATH"
fi

if [ -d "$HOME/bin" ]; then
  PATH="$HOME/bin:$PATH"
fi

if [ -d "/usr/local/bin" ]; then
  PATH="/usr/local/bin:$PATH"
fi

if [ -d "/usr/local/opt/gnu-tar/libexec/gnubin" ]; then
  PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
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

if [ -f "$HOME"/.git-completion.zsh ] && ! setopt -oq posix; then
  source "$HOME"/.git-completion.zsh
elif [ -f /usr/local/etc/zsh_completion.d/git-completion.zsh ] && ! setopt -oq posix; then
  source /usr/local/etc/zsh_completion.d/git-completion.zsh
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

# cache OS name for some conditionals
OS=$(uname -s)

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

# # brew shell completion
if [ -f /usr/local/etc/zsh_completion.d ]; then
  source /usr/local/etc/zsh_completion.d
fi

# code editor aliases for betas

if which code-insiders >/dev/null; then
  alias code=code-insiders
fi

if which direnv >/dev/null; then
  eval "$(direnv hook zsh)"
fi

# fzf is a fuzzy finder
[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh

if [ -d "$HOME"/n ]; then
  export N_PREFIX="$HOME/n"
  [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"
fi

# non-stystem node
if [ -d "$HOME/.volta" ]; then
  export VOLTA_HOME="$HOME/.volta"
  export PATH="$VOLTA_HOME/bin:$PATH"
elif [ -d "$HOME/.nodenv/shims" ]; then
  export PATH="$HOME/.nodenv/shims:$PATH"
  eval "$(nodenv init -)"
elif [ -d "$HOME/.nenv/bin" ]; then
  export PATH="$HOME/.nenv/bin:$PATH"
  eval "$(nenv init -)"
fi

# add npm completion
#if which npm > /dev/null ; then
#source <(npm completion)
#eval "`npm completion`"
#fi

# thefuck is a command spelling error fixer
eval "$(thefuck --alias)"

# autojump
[ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh

#########################
# environment variables #
#########################
# NOTE: override in .bash_secrets if desired

export EDITOR=vim # emacs is a cruel punishment on humanity
export PAGER=less
export HISTSIZE=1000
export HISTFILESIZE=2000
export HISTCONTROL=ignoredups:erasedups # don't put duplicate lines in the history
export HISTCONTROL=ignoreboth           # ignore same sucessive entries

# NOTE: leave this as the last section of this file so things in .bash_secrets can override anything else in this file
# store any access keys, credentials, etc. in $HOME/.bash_secrets
# can also be used to setup other custom things, like extra additions to $PATH or custom aliases
if [ -f "$HOME"/.bash_secrets ]; then
  source "$HOME"/.bash_secrets
fi
