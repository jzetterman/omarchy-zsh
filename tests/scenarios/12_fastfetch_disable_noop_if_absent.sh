#!/bin/bash
# Disabling when fastfetch isn't enabled is a no-op (exit 0, zshrc unchanged).
source "$(dirname "$0")/_lib.sh"

echo "== 12: disable-fastfetch is a no-op when not enabled =="

# Arrange
run_setup
cp "$HOME/.zshrc" /tmp/zshrc.snapshot

# Sanity: fastfetch not enabled
assert_file_not_contains "$HOME/.zshrc" "legendary-zsh:fastfetch-start"
assert_file_not_contains "$HOME/.zshrc" "# Show system info on new terminal sessions"

# Act
bash "$LEGENDARY_ZSH_HOME/bin/legendary-disable-fastfetch"
disable_exit=$?

# Assert: exit 0, zshrc byte-identical to snapshot
[ "$disable_exit" = "0" ] && _lz_report_pass "disable exited 0" \
  || _lz_report_fail "disable exit code: $disable_exit"
assert_files_equal "$HOME/.zshrc" /tmp/zshrc.snapshot

test_done
