#!/bin/bash

# Fresh install only — for updates, use: legendary-update
# Usage: install.sh [-b branch] [-h]

LEGENDARY_ZSH_HOME="${HOME}/.local/share/legendary-zsh"
BRANCH="master"

show_help() {
  cat <<EOF
Usage: install.sh [-b <branch>]

Installs legendary-zsh by cloning the repo to
~/.local/share/legendary-zsh, installing missing system dependencies,
and running first-time setup. Designed for the curl|bash one-liner.

Options:
  -b <branch>   Check out a non-default branch (default: master)
  -h            Show this help

Environment (non-interactive install):
  LEGENDARY_NONINTERACTIVE=1        Skip prompts; preservation-safe defaults
  LEGENDARY_STARSHIP_REPLACE=yes    Replace an existing ~/.config/starship.toml
  LEGENDARY_CHSH=yes                Change default login shell to zsh
  LEGENDARY_FASTFETCH=yes           Install fastfetch and enable on new shells

For updates, run 'legendary-update' instead of this script.
EOF
}

while getopts "b:h" opt; do
  case "$opt" in
    b) BRANCH="$OPTARG" ;;
    h) show_help; exit 0 ;;
    *) echo "Usage: install.sh [-b branch] [-h]"; exit 1 ;;
  esac
done

if [ -d "$LEGENDARY_ZSH_HOME" ]; then
  echo "legendary-zsh is already installed."
  echo "To update, run: legendary-update"
  exit 0
fi

echo "Installing legendary-zsh..."
[ "$BRANCH" != "master" ] && echo "  Branch: $BRANCH"

# Install dependencies
if ! command -v git &>/dev/null; then
  echo "Error: git is required. Install it and try again."
  exit 1
fi

git clone -b "$BRANCH" https://github.com/jzetterman/legendary-zsh.git "$LEGENDARY_ZSH_HOME" || { echo "Error: git clone failed"; exit 1; }

# Install deps and run setup
"$LEGENDARY_ZSH_HOME/bin/legendary-install-deps"
"$LEGENDARY_ZSH_HOME/bin/legendary-setup-zsh" || { echo "Error: setup failed"; exit 1; }
