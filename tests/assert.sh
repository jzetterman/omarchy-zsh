#!/bin/bash
# Shared assertion helpers. Sourced by every scenario via _lib.sh.
#
# Each assertion prints a ✓ / ✗ line and updates counters. Scenarios call
# test_done at the end to print a summary and exit with the appropriate status.

_lz_pass=0
_lz_fail=0

_lz_report_pass() {
  _lz_pass=$((_lz_pass + 1))
  echo "  ✓ $1"
}

_lz_report_fail() {
  _lz_fail=$((_lz_fail + 1))
  echo "  ✗ $1"
}

assert_file_exists() {
  if [ -e "$1" ]; then
    _lz_report_pass "exists: $1"
  else
    _lz_report_fail "missing: $1"
  fi
}

assert_file_absent() {
  if [ ! -e "$1" ]; then
    _lz_report_pass "absent: $1"
  else
    _lz_report_fail "unexpectedly present: $1"
  fi
}

assert_file_contains() {
  if grep -qF -- "$2" "$1" 2>/dev/null; then
    _lz_report_pass "$1 contains '$2'"
  else
    _lz_report_fail "$1 missing '$2'"
  fi
}

assert_file_not_contains() {
  if grep -qF -- "$2" "$1" 2>/dev/null; then
    _lz_report_fail "$1 unexpectedly contains '$2'"
  else
    _lz_report_pass "$1 does not contain '$2'"
  fi
}

assert_files_equal() {
  if cmp -s "$1" "$2" 2>/dev/null; then
    _lz_report_pass "equal: $1 == $2"
  else
    _lz_report_fail "differ: $1 != $2"
  fi
}

assert_files_differ() {
  if ! cmp -s "$1" "$2" 2>/dev/null; then
    _lz_report_pass "differ: $1 != $2"
  else
    _lz_report_fail "unexpectedly equal: $1 == $2"
  fi
}

assert_glob_empty() {
  # Assert that no paths match the given glob.
  # Usage: assert_glob_empty "$HOME"/.zshrc.backup-\*
  local matches=()
  # shellcheck disable=SC2206
  matches=( $1 )
  if [ "${#matches[@]}" -eq 0 ] || [ ! -e "${matches[0]}" ]; then
    _lz_report_pass "no matches for: $1"
  else
    _lz_report_fail "unexpected matches for $1: ${matches[*]}"
  fi
}

test_done() {
  echo ""
  echo "Passed: $_lz_pass  Failed: $_lz_fail"
  [ "$_lz_fail" -eq 0 ]
}
