set positional-arguments := true
alias format:=fmt

# show recipes
[private]
@help:
  just --list --list-prefix "  "

# Run shellcheck + shfmt
lint: fmt shellcheck

# Run shellcheck
@shellcheck:
  shellcheck gh-my
  shellcheck includes/query_*
  shellcheck includes/helper_*

# Run shfmt
fmt:
  #!/usr/bin/env bash
  set -eo pipefail

  shfmt -i 2 -w gh-my
  for file in "{{ justfile_directory() }}"/includes/*; do
    shfmt -i 2 -w "$file"
  done
