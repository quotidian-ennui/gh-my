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

_run_test_suites() {
  local suite_entry=""
  local suite_file=""

  for suite_runner in "${TEST_SUITES[@]}"; do
    suite_entry="$suite_runner"
    suite_file="${suite_entry%%:*}"
    suite_runner="${suite_entry#*:}"
    echo
    echo "## ${suite_file}"
    "$suite_runner"
  done
}

_write_github_summary() {
  local log_file="$1"
  local exitcode="${2:-0}"
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

  if [[ "$fail_count" -gt 0 || "$exitcode" -ne 0 ]]; then
    return 1
  fi

  return 0
}

{
  with_github_step_summary _run_test_suites _write_github_summary
}
