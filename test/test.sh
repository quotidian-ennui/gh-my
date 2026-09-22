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

for suite_runner in "${TEST_SUITES[@]}"; do
  "$suite_runner"
done
