#!/bin/bash
# templates/zshrc tells compinit to cache its dump at ~/.cache/zsh/zcompdump
# rather than rebuilding every shell start. After an interactive zsh has run
# at least once, the cache file should exist.
source "$(dirname "$0")/_lib.sh"

echo "== 22: compinit caches its dump for fast shell starts =="

run_setup

# Sanity: the cache shouldn't exist before a shell has run.
assert_file_absent "$HOME/.cache/zsh/zcompdump"

# Start an interactive zsh — this triggers compinit, which writes the dump.
zsh -i -c 'true' >/dev/null 2>&1

assert_file_exists "$HOME/.cache/zsh/zcompdump"

test_done
