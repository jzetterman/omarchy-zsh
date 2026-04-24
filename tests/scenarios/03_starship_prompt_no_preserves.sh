#!/bin/bash
# With an existing starship.toml and no LEGENDARY_STARSHIP_REPLACE override,
# non-interactive mode defaults to "no" and the user's config is preserved.
source "$(dirname "$0")/_lib.sh"

echo "== 03: Starship prompt defaults to 'no' — user's config preserved =="

# Arrange
mkdir -p "$HOME/.config"
printf '# user starship config\nadd_newline = false\n' > "$HOME/.config/starship.toml"
cp "$HOME/.config/starship.toml" /tmp/starship.snapshot

# Act
run_setup

# Assert: file unchanged, no backup created, prompt marker set
assert_files_equal "$HOME/.config/starship.toml" /tmp/starship.snapshot
assert_file_contains "$HOME/.config/starship.toml" "user starship config"
assert_glob_empty "$HOME/.config/starship.toml.backup-*"
assert_file_exists "$HOME/.local/state/legendary-zsh/starship-prompted"

test_done
