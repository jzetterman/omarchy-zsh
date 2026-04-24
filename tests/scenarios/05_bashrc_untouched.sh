#!/bin/bash
# Verify legendary-zsh never touches ~/.bashrc (post unmanage-bash). No file
# created if absent; existing file preserved byte-for-byte; no backup made.
source "$(dirname "$0")/_lib.sh"

echo "== 05: ~/.bashrc is not touched =="

# Arrange
printf '# my bash config\nexport FOO=bar\nalias ll="ls -la"\n' > "$HOME/.bashrc"
cp "$HOME/.bashrc" /tmp/bashrc.snapshot

# Act
run_setup

# Assert: identical to snapshot, no backup created
assert_files_equal "$HOME/.bashrc" /tmp/bashrc.snapshot
assert_file_contains "$HOME/.bashrc" "my bash config"
assert_file_contains "$HOME/.bashrc" "export FOO=bar"
assert_glob_empty "$HOME/.bashrc.backup-*"

test_done
