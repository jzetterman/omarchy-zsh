#!/bin/bash
# Regression test for #14: on apt systems where 'universe' isn't enabled,
# LEGENDARY_FASTFETCH=yes must result in fastfetch actually being installed
# (not a silent failure with a broken .zshrc entry).
source "$(dirname "$0")/_lib.sh"

echo "== 18: fastfetch installs on apt even if universe needs to be enabled =="

if ! command -v apt-get &>/dev/null; then
  _lz_report_pass "(skipped — not apt-based)"
  test_done
  exit
fi

# Arrange: strip 'universe' from apt sources so we reproduce the minimal-image
# conditions that surfaced #14 (install silently failing, setup lying about it).
for f in /etc/apt/sources.list /etc/apt/sources.list.d/ubuntu.sources; do
  [ -f "$f" ] || continue
  sudo sed -i 's/\buniverse\b//g' "$f"
done
sudo apt-get update -qq >/dev/null 2>&1 || true

# Act
run_setup LEGENDARY_FASTFETCH=yes

# Assert: the "don't lie to the user" contract — the binary must really be
# present after setup claims success.
command -v fastfetch >/dev/null && _lz_report_pass "fastfetch binary on PATH" \
  || _lz_report_fail "fastfetch binary NOT on PATH — setup lied"

assert_file_contains "$HOME/.zshrc" "# legendary-zsh:fastfetch-start"
assert_file_exists "$HOME/.local/state/legendary-zsh/fastfetch-prompted"

test_done
