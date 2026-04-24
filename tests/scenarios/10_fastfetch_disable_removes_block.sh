#!/bin/bash
# After enabling during install (LEGENDARY_FASTFETCH=yes), running
# legendary-disable-fastfetch removes the marker block while leaving the
# state marker in place (so legendary-update doesn't nag).
source "$(dirname "$0")/_lib.sh"

echo "== 10: disable-fastfetch removes the marker block =="

# Arrange: install with fastfetch enabled
stub_fastfetch
run_setup LEGENDARY_FASTFETCH=yes

# Sanity
assert_file_contains "$HOME/.zshrc" "# legendary-zsh:fastfetch-start"
assert_file_exists "$HOME/.local/state/legendary-zsh/fastfetch-prompted"

# Act
bash "$LEGENDARY_ZSH_HOME/bin/legendary-disable-fastfetch"

# Assert: block gone (no marker, no command line); state marker preserved
assert_file_not_contains "$HOME/.zshrc" "legendary-zsh:fastfetch-start"
assert_file_not_contains "$HOME/.zshrc" "legendary-zsh:fastfetch-end"
assert_file_not_contains "$HOME/.zshrc" "command -v fastfetch"
assert_file_exists "$HOME/.local/state/legendary-zsh/fastfetch-prompted"

test_done
