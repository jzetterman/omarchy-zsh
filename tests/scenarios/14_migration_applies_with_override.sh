#!/bin/bash
# The bashrc ps-syntax migration applies its fix when the user opts in
# (LEGENDARY_MIGRATE_APPLY=yes in non-interactive mode).
source "$(dirname "$0")/_lib.sh"

echo "== 14: migration applies .bashrc fix when opted in =="

install_legendary_source

# Arrange: bashrc with the problematic GNU ps syntax
printf 'case "$(ps --no-header --pid=$PPID --format=comm)" in\n' > "$HOME/.bashrc"

# Act: run the migration with explicit opt-in
LEGENDARY_NONINTERACTIVE=1 LEGENDARY_MIGRATE_APPLY=yes \
  bash "$LEGENDARY_ZSH_HOME/migrations/20260316_fix_bashrc_ps_syntax.sh"

# Assert: the bad pattern is gone, the POSIX pattern is in place
assert_file_not_contains "$HOME/.bashrc" "ps --no-header"
assert_file_contains "$HOME/.bashrc" "ps -p \$PPID -o comm="
# No leftover .bak file
assert_file_absent "$HOME/.bashrc.bak"

test_done
