#!/usr/bin/env bash
set -euo pipefail

# Defaults
dir="."
declare -a exclude_patterns=()
verbose=false

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
  -x | --exclude)
    [[ -n "${2-}" ]] || {
      echo "Error: --exclude requires a pattern" >&2
      exit 1
    }
    exclude_patterns+=("$2")
    shift 2
    ;;
  -v | --verbose)
    verbose=true
    shift
    ;;
  -h | --help)
    cat <<EOF
Usage: $0 [OPTIONS] [DIRECTORY]

Recursively detect line endings in all files under DIRECTORY (default: .),
optionally skipping paths and toggling per-file output, then always print a summary.

Options:
  -v, --verbose          Print each file:ending line as it's processed.
  -x, --exclude PATTERN  Skip any file whose path contains PATTERN.
  -h, --help             Show this help message and exit.
EOF
    exit 0
    ;;
  *)
    dir="$1"
    shift
    ;;
  esac
done

# Temp file for staging results
results=$(mktemp)
trap 'rm -f "$results"' EXIT

# 1) Walk the tree and classify each file
find "$dir" -type f | while IFS= read -r file; do
  # apply excludes
  for pat in "${exclude_patterns[@]}"; do
    [[ "$file" == *"$pat"* ]] && continue 2
  done

  desc=$(file -b "$file")
  if [[ $desc == *"CRLF line terminators"* ]]; then
    cls="CRLF"
  elif [[ $desc == *"CR line terminators"* ]]; then
    cls="CR"
  elif [[ $desc == *"LF line terminators"* ]]; then
    cls="LF"
  elif [[ $desc == *" text"* ]]; then
    cls="LF"
  else
    cls="Unknown"
  fi

  line="$file: $cls"
  # always record for summary
  echo "$line" >>"$results"
  # print only if verbose
  if $verbose; then
    echo "$line"
  fi
done

# 2) Print summary
echo
echo "Summary:"
echo "  CRLF files:  $(grep -c ': CRLF$' "$results")"
echo "  CR   files:  $(grep -c ': CR$' "$results")"
echo "  LF    files:  $(grep -c ': LF$' "$results")"
echo "  Unknown:     $(grep -c ': Unknown$' "$results")"
