#!/bin/bash
# Fresh install on a clean HOME. Verify every expected file is created, no
# unexpected files are touched, and no spurious backups are created.
source "$(dirname "$0")/_lib.sh"

echo "== 01: Fresh install on a clean HOME =="

# Preconditions: HOME is empty of anything legendary touches.
assert_file_absent "$HOME/.zshrc"
assert_file_absent "$HOME/.inputrc"
assert_file_absent "$HOME/.config/starship.toml"
assert_file_absent "$HOME/.bashrc"

# Act
run_setup

# Postconditions: legendary deployed its files; .bashrc is still untouched.
assert_file_exists "$HOME/.zshrc"
assert_file_exists "$HOME/.inputrc"
assert_file_exists "$HOME/.config/starship.toml"
assert_file_absent "$HOME/.bashrc"

# No backups should exist — nothing was replaced.
assert_glob_empty "$HOME/.zshrc.backup-*"
assert_glob_empty "$HOME/.config/starship.toml.backup-*"
assert_glob_empty "$HOME/.bashrc.backup-*"

test_done
