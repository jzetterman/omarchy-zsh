#!/bin/bash
set -e

LEGENDARY_ZSH_HOME="${HOME}/.local/share/legendary-zsh"

if [ -d "$LEGENDARY_ZSH_HOME" ]; then
  echo "Existing installation found. Updating..."
  "$LEGENDARY_ZSH_HOME/bin/legendary-update"
else
  echo "Installing legendary-zsh..."

  if ! command -v git &>/dev/null; then
    echo "Error: git is required. Install it and try again."
    exit 1
  fi

  if ! command -v zsh &>/dev/null; then
    echo "Error: zsh is required. Install it and try again."
    exit 1
  fi

  git clone https://github.com/jzetterman/legendary-zsh.git "$LEGENDARY_ZSH_HOME"
  "$LEGENDARY_ZSH_HOME/bin/legendary-setup-zsh"
fi
