#!/bin/bash

FORCE_UPGRADE="${FORCE_UPGRADE:-0}"
NONINTERACTIVE="${NONINTERACTIVE:-0}"
MAKE_TIMESTAMP="$(date +%s)"
OS="$(uname -s)"
RESTORE_TIMESTAMP="${RESTORE_TIMESTAMP:-notarealbackuptimestamp}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"
FONTS_DIR="$SCRIPT_DIR/fonts"

. "$SCRIPT_DIR/lib/install_packages.sh"
. "$SCRIPT_DIR/lib/install_dotfiles.sh"
. "$SCRIPT_DIR/lib/install_fonts.sh"
. "$SCRIPT_DIR/lib/setup_git.sh"

install() {
  backup
  deps "$@"
  setup_git
  dotfiles
  fonts
}

groups() {
  echo
  echo '***** Optional Package Groups *****'
  echo
  list_optional_groups
}

help() {
  printf "\nsetup.sh - installs some dotfiles, fonts and useful applications for terminal environments\n\n"
  echo "Commands:"

  printf "\n  Default:\n\n"
  printf "    install - runs the 'backup', 'deps' 'dotfiles', 'fonts' and 'setup_git' targets\n"
  printf "    install <group...> - same as install, but also installs optional package groups\n"

  printf "\n  Individual setup:\n\n"
  printf "    deps - will try to install dependencies\n"
  printf "    deps <group...> - installs base dependencies plus optional package groups\n"
  printf "    dotfiles - will install the new dotfiles to '~/'\n"
  printf "    fonts - will install new fonts to '~/Library/Fonts' on macOS or '~/.local/share/fonts' on other systems\n"
  printf "    groups - lists available optional package groups for the current OS\n"

  printf "\n  Utility:\n\n"
  printf "    backup - will backup current dotfiles to '~/.dotfile_backups/<current timestamp>'\n"
  printf "    restore - will restore backed up dotfiles, usage 'RESTORE_TIMESTAMP=<desired timestamp> ./setup.sh restore'\n"
  printf "    setup_git - configures git identity, prompting only when env vars or an existing custom config are unavailable\n"

  printf "\n  Flags:\n\n"
  printf "    --help - prints this help information (actually any unknown command will print the help)\n"
  printf "    Environment: NONINTERACTIVE=1 disables remaining prompts; GIT_NAME/GIT_EMAIL preseed git identity\n"
  printf "\n  Examples:\n\n"
  printf "    ./setup.sh deps azure kubernetes\n"
  printf "    ./setup.sh install aws containers\n"
  printf "    NONINTERACTIVE=1 GIT_NAME='Jane Doe' GIT_EMAIL='jane@example.com' ./setup.sh install\n"
  printf "    ./setup.sh groups\n"
  echo
}

COMMAND="${1:-install}"

if [ "$#" -gt 0 ]; then
  shift
fi

case "$COMMAND" in
backup)
  backup
  ;;
deps)
  deps "$@"
  ;;
install)
  install "$@"
  ;;
dotfiles)
  dotfiles
  ;;
fonts)
  fonts
  ;;
groups)
  groups
  ;;
restore)
  restore
  ;;
setup_git)
  setup_git
  ;;
--help | help)
  help
  ;;
*)
  help
  exit 1
  ;;
esac

echo
echo "NOTE: you will need to reload your \$SHELL config or open a new terminal for installation to take effect"
echo
