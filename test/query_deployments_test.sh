#!/usr/bin/env bash
# shellcheck disable=SC2329

REPO_ROOT=$(git rev-parse --show-toplevel)
HELPER_FUNCTIONS_FILE="$REPO_ROOT/includes/helper_functions"
QUERY_DEPLOYMENTS_FILE="$REPO_ROOT/includes/query_deployments"

test_query_deployments_repo_json_dispatches_repo_path() {
  # shellcheck disable=SC1090
  source "$HELPER_FUNCTIONS_FILE"
  # shellcheck disable=SC1090
  source "$QUERY_DEPLOYMENTS_FILE"

  local got_repo=""
  local got_format=""

  internal::repo_deploys() {
    got_repo="$1"
    got_format="$2"
  }

  OPTIND=1
  query_deployments -r acme/repo -j

  assert_eq "acme/repo" "$got_repo" "query_deployments should dispatch repo mode to repo helper"
  assert_eq "json" "$got_format" "query_deployments should pass json mode to repo helper"
}

test_query_deployments_org_topic_json_dispatches_org_path() {
  # shellcheck disable=SC1090
  source "$HELPER_FUNCTIONS_FILE"
  # shellcheck disable=SC1090
  source "$QUERY_DEPLOYMENTS_FILE"

  local got_query=""
  local got_format=""

  internal::org_deploys() {
    got_query="$1"
    got_format="$2"
  }

  OPTIND=1
  query_deployments -o acme -t platform -j

  assert_eq "org:acme topic:platform" "$got_query" "query_deployments should build org and topic query"
  assert_eq "json" "$got_format" "query_deployments should pass json mode to org helper"
}

test_query_deployments_all_orgs_json_keeps_callback_args() {
  # shellcheck disable=SC1090
  source "$HELPER_FUNCTIONS_FILE"
  # shellcheck disable=SC1090
  source "$QUERY_DEPLOYMENTS_FILE"

  local got_query=""
  local got_format=""

  helper::for_each_my_github_org() {
    local callback="$2"

    "$callback" "my-org" "$3" "$4"
  }

  internal::org_deploys() {
    got_query="$1"
    got_format="$2"
  }

  OPTIND=1
  query_deployments -g -t platform -j

  assert_eq "org:my-org topic:platform" "$got_query" "query_deployments should build org query inside all-org callback"
  assert_eq "json" "$got_format" "query_deployments should preserve json mode inside all-org callback"
}

run_query_deployments_tests() {
  local tests=(
    test_query_deployments_repo_json_dispatches_repo_path
    test_query_deployments_org_topic_json_dispatches_org_path
    test_query_deployments_all_orgs_json_keeps_callback_args
  )
  local test_name=""

  for test_name in "${tests[@]}"; do
    run_test "$test_name"
  done
}

register_test_suite run_query_deployments_tests
