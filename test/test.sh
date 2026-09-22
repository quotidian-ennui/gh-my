#!/usr/bin/env bash
# Run unit tests for shell helpers.
set -euo pipefail

TEST_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
test_file=""
suite_runner=""

# shellcheck disable=SC1091
source "$TEST_DIR/test-helpers.sh"

for test_file in "$TEST_DIR"/*_test.sh; do
  # shellcheck disable=SC1090
  source "$test_file"
done

run_test_suites() {
  for suite_runner in "${TEST_SUITES[@]}"; do
    "$suite_runner"
  done
}

write_github_summary() {
  local log_file="$1"
  local pass_count=""
  local fail_count=""

  pass_count=$(grep -c '^PASS:' "$log_file" || true)
  fail_count=$(grep -c '^FAIL:' "$log_file" || true)

  {
    echo '## Test summary'
    echo
    echo "- Passed: ${pass_count}"
    echo "- Failed: ${fail_count}"
    echo
    echo '<details><summary>Test output</summary>'
    echo
    echo '```text'
    cat "$log_file"
    echo '```'
    echo '</details>'
  } >>"$GITHUB_STEP_SUMMARY"
}

main() {
  local log_file=""
  local test_status=0

  if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    log_file=$(mktemp)
    if run_test_suites | tee "$log_file"; then
      test_status=0
    else
      test_status=$?
    fi
    write_github_summary "$log_file"
    rm -f "$log_file"
    return "$test_status"
  fi

  run_test_suites
}

{
  main "$@"
}
