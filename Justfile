set positional-arguments
set unstable
set script-interpreter := ['/usr/bin/env', 'bash', '-eo', 'pipefail']

[private]
@help:
    just --list --list-prefix "  "

[doc("Run shellcheck + shfmt")]
lint: fmt shellcheck

[doc("Run unit tests")]
[script]
test:
    test/test.sh

[doc("Run shellcheck")]
@shellcheck:
    shellcheck gh-my
    shellcheck includes/query_*
    shellcheck includes/helper_*
    shellcheck test/*.sh

[doc("Run shfmt")]
[script]
fmt:
    #
    set -eo pipefail
    shfmt -i 2 -w gh-my
    for file in "{{ justfile_directory() }}"/includes/*; do
      shfmt -i 2 -w "$file"
    done
    for file in "{{ justfile_directory() }}"/test/*.sh; do
      shfmt -i 2 -w "$file"
    done

alias format := fmt
