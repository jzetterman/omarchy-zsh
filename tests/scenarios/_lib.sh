#!/bin/bash
# Shared helpers for test scenarios. Each scenario sources this file.
#
# Assumes the repo is mounted read-only at /repo inside the container
# (set up by tests/run.sh).

export LEGENDARY_ZSH_HOME="$HOME/.local/share/legendary-zsh"

# Source the assertion helpers.
_this_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../assert.sh
source "$_this_dir/../assert.sh"
unset _this_dir

# Remove every file legendary-zsh could touch so each scenario starts from a
# known-clean state. Distro base images (Arch, Ubuntu, Fedora) ship with a
# /etc/skel .bashrc that's copied to new user HOMEs — we clear it here so
# assertions about "bashrc absent" don't trip.
reset_home() {
  rm -rf \
    "$HOME/.zshrc" \
    "$HOME/.bashrc" \
    "$HOME/.inputrc" \
    "$HOME/.config/starship.toml" \
    "$HOME/.local/share/legendary-zsh" \
    "$HOME/.local/state/legendary-zsh"
  # shellcheck disable=SC2086
  rm -f $HOME/.zshrc.backup-* \
        $HOME/.bashrc.backup-* \
        $HOME/.config/starship.toml.backup-* 2>/dev/null || true
}

# Auto-reset when the library is sourced so scenarios start with a blank slate.
reset_home

# Stage the repo at $LEGENDARY_ZSH_HOME. Pre-creates the plugin subdirs so
# legendary-setup-zsh skips the git clones — keeps tests fast and avoids
# network flakiness.
install_legendary_source() {
  mkdir -p "$LEGENDARY_ZSH_HOME"
  cp -r /repo/. "$LEGENDARY_ZSH_HOME/"
  for p in zsh-syntax-highlighting zsh-autosuggestions zsh-completions fzf-tab; do
    mkdir -p "$LEGENDARY_ZSH_HOME/plugins/$p"
  done
}

# Run legendary-setup-zsh in non-interactive mode. Any additional args are
# passed through as VAR=value overrides.
#   run_setup                               # default (everything declined)
#   run_setup LEGENDARY_STARSHIP_REPLACE=yes
run_setup() {
  install_legendary_source
  env LEGENDARY_NONINTERACTIVE=1 "$@" bash "$LEGENDARY_ZSH_HOME/bin/legendary-setup-zsh"
}

# Run legendary-uninstall in non-interactive mode with confirmation on by
# default. Override-capable via additional VAR=value args.
run_uninstall() {
  env LEGENDARY_NONINTERACTIVE=1 LEGENDARY_UNINSTALL_CONFIRM=yes "$@" \
    bash "$LEGENDARY_ZSH_HOME/bin/legendary-uninstall"
}

# Plant a stub fastfetch binary on PATH so scripts that check
# `command -v fastfetch` find one and skip the package install (which would
# need network and real root). Use in scenarios that exercise the enable /
# install path.
stub_fastfetch() {
  sudo sh -c 'printf "#!/bin/sh\necho \"(stub fastfetch)\"\n" > /usr/local/bin/fastfetch && chmod +x /usr/local/bin/fastfetch'
}
