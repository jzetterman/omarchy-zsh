#!/bin/bash
# Without the LEGENDARY_MIGRATE_APPLY override, non-interactive migrations
# must decline to modify user dotfiles — the safe default.
source "$(dirname "$0")/_lib.sh"

echo "== 15: migration declines (NONINTERACTIVE default) preserves .bashrc =="

install_legendary_source

# Arrange: bashrc with the problematic syntax; snapshot it
printf 'case "$(ps --no-header --pid=$PPID --format=comm)" in\n' > "$HOME/.bashrc"
cp "$HOME/.bashrc" /tmp/bashrc.snapshot

# Act: non-interactive with no override — should decline
LEGENDARY_NONINTERACTIVE=1 \
  bash "$LEGENDARY_ZSH_HOME/migrations/20260316_fix_bashrc_ps_syntax.sh"
migrate_exit=$?

# Assert: exit 0 (clean decline, not a failure), file byte-identical
[ "$migrate_exit" = "0" ] && _lz_report_pass "migration exited 0 on decline" \
  || _lz_report_fail "migration exit code: $migrate_exit"
assert_files_equal "$HOME/.bashrc" /tmp/bashrc.snapshot
assert_file_contains "$HOME/.bashrc" "ps --no-header"

test_done
