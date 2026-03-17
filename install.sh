#!/bin/bash

# Fresh install only — for updates, use: legendary-update

LEGENDARY_ZSH_HOME="${HOME}/.local/share/legendary-zsh"

if [ -d "$LEGENDARY_ZSH_HOME" ]; then
  echo "legendary-zsh is already installed."
  echo "To update, run: legendary-update"
  exit 0
fi

echo "Installing legendary-zsh..."

# Install dependencies
if ! command -v git &>/dev/null; then
  echo "Error: git is required. Install it and try again."
  exit 1
fi

git clone https://github.com/jzetterman/legendary-zsh.git "$LEGENDARY_ZSH_HOME" || { echo "Error: git clone failed"; exit 1; }

# Install deps and run setup
"$LEGENDARY_ZSH_HOME/bin/legendary-install-deps"
"$LEGENDARY_ZSH_HOME/bin/legendary-setup-zsh" || { echo "Error: setup failed"; exit 1; }
