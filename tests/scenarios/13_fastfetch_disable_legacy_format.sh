#!/bin/bash
# legendary-disable-fastfetch handles the legacy (pre-marker) format that
# older installs wrote into ~/.zshrc. This protects users upgrading from
# before the marker change.
source "$(dirname "$0")/_lib.sh"

echo "== 13: disable-fastfetch handles the legacy format =="

# Arrange: fresh install, then inject the legacy snippet manually
run_setup
printf '\n# Show system info on new terminal sessions\ncommand -v fastfetch &>/dev/null && fastfetch\n' >> "$HOME/.zshrc"

# Sanity
assert_file_contains "$HOME/.zshrc" "# Show system info on new terminal sessions"

# Act
bash "$LEGENDARY_ZSH_HOME/bin/legendary-disable-fastfetch"

# Assert: legacy lines gone
assert_file_not_contains "$HOME/.zshrc" "# Show system info on new terminal sessions"
assert_file_not_contains "$HOME/.zshrc" "command -v fastfetch"

test_done
