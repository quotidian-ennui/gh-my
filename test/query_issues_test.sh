#!/usr/bin/env bash
# shellcheck disable=SC2329

REPO_ROOT=$(git rev-parse --show-toplevel)
HELPER_FUNCTIONS_FILE="$REPO_ROOT/includes/helper_functions"
QUERY_ISSUES_FILE="$REPO_ROOT/includes/query_issues"

test_query_issues_json_uses_std_graphql() {
  # shellcheck disable=SC1090
  source "$HELPER_FUNCTIONS_FILE"
  # shellcheck disable=SC1090
  source "$QUERY_ISSUES_FILE"

  local got_format=""
  local got_args=""
  local got_query=""

  helper::std_output_format() {
    got_args="$*"
    STD_OUTPUT_FORMAT="json"
    got_format="$STD_OUTPUT_FORMAT"
  }

  helper::std_graphql() {
    got_query="$1"
  }

  OPTIND=1
  query_issues -j

  assert_eq "-j" "$got_args" "query_issues should forward flags to std_output_format"
  assert_eq "json" "$got_format" "query_issues should select json mode"
  assert_contains "$got_query" 'is:open is:issue user:@me archived:false' "query_issues should build expected issue query"
}

test_query_issues_table_mode_uses_default_format() {
  # shellcheck disable=SC1090
  source "$HELPER_FUNCTIONS_FILE"
  # shellcheck disable=SC1090
  source "$QUERY_ISSUES_FILE"

  local got_format=""
  local got_query=""

  helper::std_output_format() {
    STD_OUTPUT_FORMAT="table"
    got_format="$STD_OUTPUT_FORMAT"
  }

  helper::std_graphql() {
    got_query="$1"
  }

  OPTIND=1
  query_issues

  assert_eq "table" "$got_format" "query_issues should keep table mode by default"
  assert_contains "$got_query" '... on Issue {' "query_issues should request issue fields"
}

run_query_issues_tests() {
  local tests=(
    test_query_issues_json_uses_std_graphql
    test_query_issues_table_mode_uses_default_format
  )
  local test_name=""

  for test_name in "${tests[@]}"; do
    run_test "$test_name"
  done
}

register_test_suite run_query_issues_tests
