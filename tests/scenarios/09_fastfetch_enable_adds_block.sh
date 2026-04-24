#!/bin/bash
# legendary-enable-fastfetch appends the marker-wrapped block to ~/.zshrc and
# touches the state marker so subsequent legendary-update runs don't re-ask.
source "$(dirname "$0")/_lib.sh"

echo "== 09: enable-fastfetch adds the marker block and state marker =="

# Arrange: install legendary (fastfetch not enabled by default)
stub_fastfetch
run_setup

# Sanity: fastfetch is not yet in zshrc, marker exists from the prompt
assert_file_not_contains "$HOME/.zshrc" "legendary-zsh:fastfetch-start"
assert_file_exists "$HOME/.local/state/legendary-zsh/fastfetch-prompted"

# Act
bash "$LEGENDARY_ZSH_HOME/bin/legendary-enable-fastfetch"

# Assert: marker block appended, state marker still present
assert_file_contains "$HOME/.zshrc" "# legendary-zsh:fastfetch-start"
assert_file_contains "$HOME/.zshrc" "# legendary-zsh:fastfetch-end"
assert_file_contains "$HOME/.zshrc" "command -v fastfetch"
assert_file_exists "$HOME/.local/state/legendary-zsh/fastfetch-prompted"

test_done
