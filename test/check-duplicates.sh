#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
SELF_PATH="$REPO_ROOT/test/check-duplicates.sh"
TEST_RUNNER_PATH="$REPO_ROOT/test/test.sh"
source "$REPO_ROOT/test/test-helpers.sh"

_should_skip() {
  local target_file="$1"
  local target_path=""

  [[ ! -f "$target_file" ]] && return 0
  target_path=$(realpath "$target_file")
  [[ "$target_path" == "$SELF_PATH" ]] && return 0
  [[ "$target_path" == "$TEST_RUNNER_PATH" ]] && return 0
  return 1
}

_collect_file_functions() {
  local target_file="$1"

  sed -nE 's/^([[:alnum:]_:-]+)[[:space:]]*\(\)[[:space:]]*\{.*/\1/p' "$target_file"
}

_collect_target_files() {
  shopt -s nullglob
  printf '%s\n' "$REPO_ROOT"/includes/* "$REPO_ROOT"/test/*
}

_record_file_functions() {
  local target_file="$1"
  local function_name=""

  while IFS= read -r function_name; do
    [[ -z "$function_name" ]] && continue
    if [[ -n "${seen[$function_name]:-}" ]]; then
      echo "duplicate function: ${function_name}"
      echo "  first seen in: ${source_of[$function_name]}"
      echo "  duplicated in: ${target_file}"
      return 1
    fi
    seen["$function_name"]=1
    source_of["$function_name"]="$target_file"
  done < <(_collect_file_functions "$target_file")
}

_write_github_summary() {
  local log_file="$1"
  local exitcode="$2"

  {
    echo '## Duplicate Function Check Summary'
    echo
    echo "- Exit Code: ${exitcode}"
    echo
    echo '<details><summary>Output</summary>'
    echo
    echo '```text'
    cat "$log_file"
    echo '```'
    echo '</details>'
  } >>"$GITHUB_STEP_SUMMARY"
}

_run_check_duplicates() {
  local target_file=""
  local status=0
  declare -A seen=()
  declare -A source_of=()

  for target_file in $(_collect_target_files); do
    if _should_skip "$target_file"; then
      continue
    fi

    if ! _record_file_functions "$target_file"; then
      status=1
    fi
  done

  return "$status"
}

{
  with_github_step_summary _run_check_duplicates _write_github_summary
}
