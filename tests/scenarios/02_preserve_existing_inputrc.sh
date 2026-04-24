#!/bin/bash
# An existing ~/.inputrc must be left completely alone. No replace, no backup.
source "$(dirname "$0")/_lib.sh"

echo "== 02: Preserve existing ~/.inputrc =="

# Arrange
printf '# user-custom inputrc\nset bell-style none\n' > "$HOME/.inputrc"
cp "$HOME/.inputrc" /tmp/inputrc.snapshot

# Act
run_setup

# Assert: file identical to snapshot, content intact
assert_files_equal "$HOME/.inputrc" /tmp/inputrc.snapshot
assert_file_contains "$HOME/.inputrc" "user-custom inputrc"
assert_file_contains "$HOME/.inputrc" "set bell-style none"

test_done
