#!/usr/bin/env bash
# shellcheck disable=SC2329

REPO_ROOT=$(git rev-parse --show-toplevel)
HELPER_FUNCTIONS_FILE="$REPO_ROOT/includes/helper_functions"
QUERY_PRS_FILE="$REPO_ROOT/includes/query_prs"

test_query_prs_json_dispatches_direct_query() {
  # shellcheck disable=SC1090
  source "$HELPER_FUNCTIONS_FILE"
  # shellcheck disable=SC1090
  source "$QUERY_PRS_FILE"

  local got_query=""
  local got_format=""
  local got_url_first=""

  _prs_repo_query() {
    echo 'repo:seed'
  }

  _prs_do_query() {
    got_query="$1"
    got_format="$2"
    got_url_first="$3"
  }

  OPTIND=1
  query_prs -j

  assert_eq "repo:seed" "$got_query" "query_prs should use repo query by default"
  assert_eq "json" "$got_format" "query_prs should switch to json mode"
  assert_eq "false" "$got_url_first" "query_prs should keep default url mode"
}

test_query_prs_all_orgs_json_keeps_json_through_callback() {
  # shellcheck disable=SC1090
  source "$HELPER_FUNCTIONS_FILE"
  # shellcheck disable=SC1090
  source "$QUERY_PRS_FILE"

  local got_query=""
  local got_format=""
  local got_url_first=""

  _prs_repo_query() {
    echo 'repo:seed'
  }

  helper::for_each_my_github_org() {
    local callback="$2"

    "$callback" "my-org" "$3" "$4"
  }

  _prs_do_query() {
    got_query="$1"
    got_format="$2"
    got_url_first="$3"
  }

  OPTIND=1
  query_prs -gj

  assert_contains "$got_query" "org:my-org" "query_prs should build org query in -g mode"
  assert_eq "json" "$got_format" "query_prs should keep json mode in org callback path"
  assert_eq "false" "$got_url_first" "query_prs should keep default url mode"
}

test_query_prs_org_option_builds_org_query() {
  # shellcheck disable=SC1090
  source "$HELPER_FUNCTIONS_FILE"
  # shellcheck disable=SC1090
  source "$QUERY_PRS_FILE"

  local got_query=""
  local got_format=""

  _prs_repo_query() {
    echo 'repo:seed'
  }

  _prs_do_query() {
    got_query="$1"
    got_format="$2"
  }

  OPTIND=1
  query_prs -o acme -j

  assert_contains "$got_query" "org:acme" "query_prs should target requested org"
  assert_eq "json" "$got_format" "query_prs should keep json mode with explicit org"
}

run_query_prs_tests() {
  local tests=(
    test_query_prs_json_dispatches_direct_query
    test_query_prs_all_orgs_json_keeps_json_through_callback
    test_query_prs_org_option_builds_org_query
  )
  local test_name=""

  for test_name in "${tests[@]}"; do
    run_test "$test_name"
  done
}

register_test_suite run_query_prs_tests
