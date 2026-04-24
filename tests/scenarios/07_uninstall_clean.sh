#!/bin/bash
# On a HOME with no prior configs, install + uninstall leaves the system clean:
# legendary's files are gone, state dir is gone, and the repo checkout is gone.
source "$(dirname "$0")/_lib.sh"

echo "== 07: Uninstall removes legendary's files =="

# Arrange: fresh install
run_setup

# Sanity: install actually created its files
assert_file_exists "$HOME/.zshrc"
assert_file_exists "$HOME/.inputrc"
assert_file_exists "$HOME/.config/starship.toml"
assert_file_exists "$LEGENDARY_ZSH_HOME"

# Act
run_uninstall

# Assert: legendary's files are all gone
assert_file_absent "$HOME/.zshrc"
assert_file_absent "$HOME/.inputrc"
assert_file_absent "$HOME/.config/starship.toml"
assert_file_absent "$LEGENDARY_ZSH_HOME"
assert_file_absent "$HOME/.local/state/legendary-zsh"

test_done
