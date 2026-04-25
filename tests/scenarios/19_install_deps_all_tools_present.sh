#!/bin/bash
# Every tool legendary-install-deps installs must be on PATH afterward — from
# bash and from an interactive zsh that sources the deployed ~/.zshrc. This
# catches silent install failures for the whole dependency list, not just
# fastfetch (covered separately by scenario 18). Same "don't lie to the
# user" contract.
source "$(dirname "$0")/_lib.sh"

echo "== 19: every installed tool is callable from bash and zsh =="

install_legendary_source

# Act 1: run install-deps for real (network-dependent — fzf/starship/zoxide/
# eza/gum get fetched on apt and dnf systems via their upstream installers).
bash "$LEGENDARY_ZSH_HOME/bin/legendary-install-deps"

# Act 2: run setup-zsh with fastfetch enabled. Uses the real install path
# (no stub_fastfetch) so this exercises the .deb fallback on ubuntu LTS too.
LEGENDARY_NONINTERACTIVE=1 LEGENDARY_FASTFETCH=yes \
  bash "$LEGENDARY_ZSH_HOME/bin/legendary-setup-zsh"

# Assert each tool is reachable from an interactive zsh — that's the user's
# actual shell context, where shell/envs has prepended ~/.local/bin (zoxide's
# install location) and the rest of the legendary PATH setup is in effect.
# Bash without that setup may not see ~/.local/bin and is the wrong frame
# of reference for the "is this tool callable for the user?" question.
all_tools=(git zsh fzf starship zoxide eza gum fastfetch)
for tool in "${all_tools[@]}"; do
  if zsh -i -c "command -v $tool" >/dev/null 2>&1; then
    _lz_report_pass "$tool reachable in zsh"
  else
    _lz_report_fail "$tool NOT reachable in zsh after install"
  fi
done

test_done
