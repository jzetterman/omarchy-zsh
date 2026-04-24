#!/bin/bash
# Every legendary-* command (and install.sh) accepts --help and exits 0 with
# non-empty usage output.
source "$(dirname "$0")/_lib.sh"

echo "== 16: --help works on every legendary-* command =="

install_legendary_source

commands=(
  legendary-setup-zsh
  legendary-install-deps
  legendary-update
  legendary-migrate
  legendary-uninstall
  legendary-disable-fastfetch
  legendary-enable-fastfetch
  legendary-path-add
)

for cmd in "${commands[@]}"; do
  output="$("$LEGENDARY_ZSH_HOME/bin/$cmd" --help 2>&1)"
  rc=$?
  if [ "$rc" = "0" ] && [ -n "$output" ]; then
    _lz_report_pass "$cmd --help exits 0 with output"
  else
    _lz_report_fail "$cmd --help: rc=$rc, output=${output:0:60}"
  fi
done

# Spot-check the short -h form on a couple of scripts
for cmd in legendary-update legendary-uninstall; do
  output="$("$LEGENDARY_ZSH_HOME/bin/$cmd" -h 2>&1)"
  rc=$?
  if [ "$rc" = "0" ] && [ -n "$output" ]; then
    _lz_report_pass "$cmd -h exits 0 with output"
  else
    _lz_report_fail "$cmd -h: rc=$rc"
  fi
done

# install.sh (the curl|bash entry point) also supports -h
output="$(bash "$LEGENDARY_ZSH_HOME/install.sh" -h 2>&1)"
rc=$?
if [ "$rc" = "0" ] && [ -n "$output" ]; then
  _lz_report_pass "install.sh -h exits 0 with output"
else
  _lz_report_fail "install.sh -h: rc=$rc"
fi

test_done
