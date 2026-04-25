#!/bin/bash
# legendary-path-add appends to ~/.config/legendary-zsh/paths. shell/envs
# reads that file every shell startup and prepends each entry (whose
# directory exists) to PATH. Entries must therefore persist across new
# terminal sessions.
#
# Regression test: verifies that adding a path makes it available in fresh
# zsh sessions, and that adding a second one doesn't drop the first.
source "$(dirname "$0")/_lib.sh"

echo "== 20: legendary-path-add entries persist across new shells =="

run_setup

# Add a path. The directory needs to exist so shell/envs's _lz_prepend
# accepts it (skipping non-existent dirs is intentional).
mkdir -p "$HOME/my-custom-bin"
"$LEGENDARY_ZSH_HOME/bin/legendary-path-add" "$HOME/my-custom-bin" >/dev/null

assert_file_contains "$HOME/.config/legendary-zsh/paths" "my-custom-bin"

# Open a brand-new zsh and check the PATH it sees.
new_path="$(zsh -i -c 'echo $PATH' 2>/dev/null)"
case ":$new_path:" in
  *":$HOME/my-custom-bin:"*) _lz_report_pass "first entry on PATH in new shell" ;;
  *) _lz_report_fail "first entry NOT on PATH in new shell. Got: $new_path" ;;
esac

# Add a second entry — the first must survive.
mkdir -p "$HOME/another-bin"
"$LEGENDARY_ZSH_HOME/bin/legendary-path-add" "$HOME/another-bin" >/dev/null

assert_file_contains "$HOME/.config/legendary-zsh/paths" "my-custom-bin"
assert_file_contains "$HOME/.config/legendary-zsh/paths" "another-bin"

new_path="$(zsh -i -c 'echo $PATH' 2>/dev/null)"
case ":$new_path:" in
  *":$HOME/my-custom-bin:"*) _lz_report_pass "first entry still on PATH after second add" ;;
  *) _lz_report_fail "first entry lost after second add" ;;
esac
case ":$new_path:" in
  *":$HOME/another-bin:"*) _lz_report_pass "second entry on PATH" ;;
  *) _lz_report_fail "second entry NOT on PATH" ;;
esac

test_done
