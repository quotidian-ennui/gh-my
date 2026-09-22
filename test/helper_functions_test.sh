#!/usr/bin/env bash
# shellcheck disable=SC2329

REPO_ROOT=$(git rev-parse --show-toplevel)
HELPER_FUNCTIONS_FILE="$REPO_ROOT/includes/helper_functions"

test_helper_gh_api_adds_headers() {
  # shellcheck disable=SC1090
  source "$HELPER_FUNCTIONS_FILE"
  local calls=()

  gh() {
    calls+=("$*")
  }

  helper::gh_api graphql --paginate

  assert_eq "api -H $GH_REST_API_VERSION -H $GH_ACCEPT graphql --paginate" "${calls[0]}" "helper::gh_api should prepend GitHub API headers"
}

test_helper_compress_query_strips_newlines() {
  # shellcheck disable=SC1090
  source "$HELPER_FUNCTIONS_FILE"
  local output=""

  output=$(helper::compressQuery $'line one\nline two\n')

  assert_eq "line oneline two" "$output" "helper::compressQuery should remove newline characters"
}

test_helper_std_output_format_sets_json() {
  # shellcheck disable=SC1090
  source "$HELPER_FUNCTIONS_FILE"

  STD_OUTPUT_FORMAT="table"
  OPTIND=1
  helper::std_output_format -j

  assert_eq "json" "$STD_OUTPUT_FORMAT" "helper::std_output_format should switch output format to json"
}

test_helper_std_graphql_json_mode() {
  # shellcheck disable=SC1090
  source "$HELPER_FUNCTIONS_FILE"
  local log_file=""
  local log_contents=""
  local output=""

  log_file=$(mktemp)

  gh() {
    printf '%s\n' "$*" >>"$log_file"
    printf '%s\n' '{"ok":true}'
  }

  STD_OUTPUT_FORMAT="json"
  output=$(helper::std_graphql $'query line\nnext line')
  log_contents=$(cat "$log_file")
  rm -f "$log_file"

  assert_eq '{"ok":true}' "$output" "helper::std_graphql should emit jq-compressed json in json mode"
  assert_contains "$log_contents" "api graphql --paginate --raw-field query=query linenext line --jq $STD_JQ_FILTER" "helper::std_graphql should call gh graphql with jq filter in json mode"
}

test_helper_std_graphql_table_mode() {
  # shellcheck disable=SC1090
  source "$HELPER_FUNCTIONS_FILE"
  local log_file=""
  local log_contents=""
  local output=""

  log_file=$(mktemp)

  gh() {
    printf '%s\n' "$*" >>"$log_file"
    printf '%s\n' 'table-output'
  }

  STD_OUTPUT_FORMAT="table"
  output=$(helper::std_graphql 'query line')
  log_contents=$(cat "$log_file")
  rm -f "$log_file"

  assert_eq 'table-output' "$output" "helper::std_graphql should pass template output through in table mode"
  assert_contains "$log_contents" "api graphql --paginate --raw-field query=query line --template=" "helper::std_graphql should call gh graphql with template in table mode"
}

test_helper_is_repo_true_when_gh_repo_view_succeeds() {
  # shellcheck disable=SC1090
  source "$HELPER_FUNCTIONS_FILE"

  gh() {
    return 0
  }

  helper::is_repo
}

test_helper_is_repo_false_when_gh_repo_view_fails() {
  # shellcheck disable=SC1090
  source "$HELPER_FUNCTIONS_FILE"

  gh() {
    return 1
  }

  if helper::is_repo; then
    echo "helper::is_repo should fail when gh repo view fails"
    return 1
  fi
}

test_helper_repo_info_formats_owner_and_repo() {
  # shellcheck disable=SC1090
  source "$HELPER_FUNCTIONS_FILE"
  local output=""

  gh() {
    printf '%s\n' '{"name":"gh-my","owner":{"login":"quotidian-ennui"}}'
  }

  output=$(helper::repo_info)

  assert_eq 'quotidian-ennui/gh-my' "$output" "helper::repo_info should format owner and repo name"
}

test_helper_my_github_orgs_filters_excluded_orgs() {
  export GH_MY_IGNORE_ORGS='skip-me'
  # shellcheck disable=SC1090
  source "$HELPER_FUNCTIONS_FILE"
  local output=""

  gh() {
    printf '%s\n' 'keep-one' 'skip-me' 'keep-two'
  }

  output=$(helper::my_github_orgs)

  assert_eq 'keep-one keep-two' "$output" "helper::my_github_orgs should exclude ignored orgs"
}

test_helper_for_each_my_github_org_table_mode() {
  # shellcheck disable=SC1090
  source "$HELPER_FUNCTIONS_FILE"
  local output=""

  helper::my_github_orgs() {
    echo 'org-one org-two'
  }

  callback() {
    printf 'callback:%s:%s:%s\n' "$1" "$2" "$3"
  }

  output=$(helper::for_each_my_github_org table callback extra-one extra-two)

  assert_contains "$output" '🏛️ org-one' "helper::for_each_my_github_org should print org heading in table mode"
  assert_contains "$output" 'callback:org-one:extra-one:extra-two' "helper::for_each_my_github_org should pass org and callback args"
  assert_contains "$output" 'callback:org-two:extra-one:extra-two' "helper::for_each_my_github_org should iterate every org"
}

test_helper_for_each_my_github_org_json_mode() {
  # shellcheck disable=SC1090
  source "$HELPER_FUNCTIONS_FILE"
  local output=""

  helper::my_github_orgs() {
    echo 'org-one'
  }

  callback() {
    printf 'callback:%s:%s\n' "$1" "$2"
  }

  output=$(helper::for_each_my_github_org json callback extra-one)

  assert_eq 'callback:org-one:extra-one' "$output" "helper::for_each_my_github_org should skip org heading in json mode"
}

test_helper_list_my_org_repos_lists_each_org() {
  # shellcheck disable=SC1090
  source "$HELPER_FUNCTIONS_FILE"
  local output=""

  helper::my_github_orgs() {
    echo 'org-one org-two'
  }

  gh() {
    if [[ "$1" == 'repo' && "$2" == 'list' ]]; then
      printf '%s/repo\n' "$3"
      return 0
    fi
    return 1
  }

  output=$(helper::list_my_org_repos)

  assert_eq $'org-one/repo\norg-two/repo' "$output" "helper::list_my_org_repos should list repos for each org"
}

test_helper_gh_whoami_prefers_configured_user() {
  # shellcheck disable=SC1090
  source "$HELPER_FUNCTIONS_FILE"
  local output=""

  gh() {
    if [[ "$*" == 'config get user -h github.com' ]]; then
      printf '%s\n' 'alice'
      return 0
    fi
    return 1
  }

  output=$(helper::gh_whoami)

  assert_eq 'alice' "$output" "helper::gh_whoami should use configured gh username first"
}

test_helper_gh_whoami_falls_back_to_auth_status() {
  # shellcheck disable=SC1090
  source "$HELPER_FUNCTIONS_FILE"
  local output=""

  gh() {
    if [[ "$*" == 'config get user -h github.com' ]]; then
      return 1
    fi
    if [[ "$*" == 'auth status -h github.com' ]]; then
      printf '%s\n' '  ✓ Logged in to github.com account bob (/tmp/hosts.yml)'
      return 0
    fi
    return 1
  }

  output=$(helper::gh_whoami)

  assert_eq 'bob' "$output" "helper::gh_whoami should parse gh auth status when config is empty"
}

run_helper_function_tests() {
  local tests=(
    test_helper_gh_api_adds_headers
    test_helper_compress_query_strips_newlines
    test_helper_std_output_format_sets_json
    test_helper_std_graphql_json_mode
    test_helper_std_graphql_table_mode
    test_helper_is_repo_true_when_gh_repo_view_succeeds
    test_helper_is_repo_false_when_gh_repo_view_fails
    test_helper_repo_info_formats_owner_and_repo
    test_helper_my_github_orgs_filters_excluded_orgs
    test_helper_for_each_my_github_org_table_mode
    test_helper_for_each_my_github_org_json_mode
    test_helper_list_my_org_repos_lists_each_org
    test_helper_gh_whoami_prefers_configured_user
    test_helper_gh_whoami_falls_back_to_auth_status
  )
  local test_name=""

  for test_name in "${tests[@]}"; do
    run_test "$test_name"
  done
}

register_test_suite run_helper_function_tests
