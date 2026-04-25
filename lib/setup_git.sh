# shellcheck shell=bash

setup_git() {
  local git_name="${GIT_NAME:-${GIT_COMMIT_NAME:-}}"
  local git_email="${GIT_EMAIL:-${GIT_COMMIT_EMAIL:-}}"

  echo
  echo '***** Setting up git user information *****'
  echo

  if [ -n "$git_name" ] && [ -n "$git_email" ]; then
    printf "Using git identity from environment\n"
  elif [ -f "$HOME/.gitconfig_custom" ] && [ "$FORCE_UPGRADE" != 1 ]; then
    printf "Existing ~/.gitconfig_custom found, leaving it unchanged\n"
    return 0
  elif [ "$NONINTERACTIVE" = 1 ]; then
    printf "Skipping git identity prompt in non-interactive mode; set GIT_NAME and GIT_EMAIL to configure it automatically\n"
    return 0
  else
    echo "Enter the name for your git commits, followed by [ENTER]:"
    read -r git_name

    echo

    echo "Enter the email address for your git commits, followed by [ENTER]:"
    read -r git_email
  fi

  echo "[user]
  name = $git_name
  email = $git_email
  " >"$HOME/.gitconfig_custom"
}
