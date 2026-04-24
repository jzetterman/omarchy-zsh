#!/bin/bash
# If the user declined starship replacement during install, uninstall must
# leave the user's ~/.config/starship.toml exactly as it was — legendary
# never managed that file.
source "$(dirname "$0")/_lib.sh"

echo "== 08: Uninstall leaves user's starship.toml intact =="

# Arrange
mkdir -p "$HOME/.config"
printf '# user starship config\nadd_newline = false\n' > "$HOME/.config/starship.toml"
cp "$HOME/.config/starship.toml" /tmp/starship.snapshot

# Install declining the starship replacement (default NONINTERACTIVE behavior)
run_setup

# Sanity: install did not touch the user's starship.toml
assert_files_equal "$HOME/.config/starship.toml" /tmp/starship.snapshot

# Act
run_uninstall

# Assert: user's starship.toml still there and unchanged
assert_file_exists "$HOME/.config/starship.toml"
assert_files_equal "$HOME/.config/starship.toml" /tmp/starship.snapshot
assert_file_contains "$HOME/.config/starship.toml" "user starship config"

test_done
