#!/usr/bin/env bash

TEST_SUITES=()

register_test_suite() {
  local suite_runner="$1"
  local suite_file=""

  suite_file=$(basename "${BASH_SOURCE[1]}")
  TEST_SUITES+=("${suite_file}:${suite_runner}")
}

assert_eq() {
  local expected="$1"
  local actual="$2"
  local message="$3"

  if [[ "$expected" != "$actual" ]]; then
    echo "FAIL: $message"
    echo "expected: [$expected]"
    echo "actual:   [$actual]"
    return 1
  fi
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local message="$3"

  if [[ "$haystack" != *"$needle"* ]]; then
    echo "FAIL: $message"
    echo "missing: [$needle]"
    echo "actual:  [$haystack]"
    return 1
  fi
}

run_test() {
  local test_name="$1"

  if (
    set -euo pipefail
    "$test_name"
  ); then
    echo "PASS: $test_name"
  else
    echo "FAIL: $test_name"
    return 1
  fi
}
