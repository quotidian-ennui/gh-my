set positional-arguments
set unstable
set script-interpreter := ['/usr/bin/env', 'bash', '-eo', 'pipefail']

[private]
@help:
    just --list --list-prefix "  "

[doc("Run shellcheck + shfmt")]
[group("housekeeping")]
lint: fmt shellcheck

[doc("Run all the checks")]
[group("dev")]
check: test duplicates

[doc("Run unit tests")]
[group("dev")]
@test:
    test/test.sh

[doc("Check duplicate sourced test functions")]
[group("dev")]
@duplicates:
    test/check-duplicates.sh

[doc("Run shellcheck")]
[group("housekeeping")]
@shellcheck:
    shellcheck gh-my
    shellcheck includes/query_*
    shellcheck includes/helper_*
    shellcheck test/*.sh

[doc("Run shfmt")]
[group("housekeeping")]
[script]
fmt:
    shfmt -i 2 -w gh-my
    for file in "{{ justfile_directory() }}"/includes/*; do
      shfmt -i 2 -w "$file"
    done
    for file in "{{ justfile_directory() }}"/test/*.sh; do
      shfmt -i 2 -w "$file"
    done

alias format := fmt
