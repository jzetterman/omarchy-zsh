#!/bin/bash
# User customizations below the "Add your own customizations below" marker in
# ~/.zshrc must survive a setup run (the pre-existing marker-based extraction
# from Changeset 1 / commit 8b49d55).
source "$(dirname "$0")/_lib.sh"

echo "== 06: User customizations in ~/.zshrc are preserved =="

# Arrange: pre-populate ~/.zshrc with the marker and user content below it.
cat > "$HOME/.zshrc" <<'EOF'
# (legendary-zsh content would be here)

# Add your own customizations below
export MY_CUSTOM_VAR=foo
alias mything='echo hi'
EOF

# Act
run_setup

# Assert: user lines preserved after the template was re-deployed
assert_file_contains "$HOME/.zshrc" "export MY_CUSTOM_VAR=foo"
assert_file_contains "$HOME/.zshrc" "alias mything='echo hi'"
# And a backup should exist (setup always backs up the existing .zshrc).
latest_backup="$(ls -t "$HOME"/.zshrc.backup-* 2>/dev/null | head -1)"
if [ -n "$latest_backup" ]; then
  _lz_report_pass "zshrc backup created: $(basename "$latest_backup")"
else
  _lz_report_fail "no zshrc backup created"
fi

test_done
