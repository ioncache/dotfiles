# shellcheck shell=bash

if [ -s "$HOME/.profile" ]; then
	# shellcheck disable=SC1090,SC1091
	source "$HOME/.profile"
fi
