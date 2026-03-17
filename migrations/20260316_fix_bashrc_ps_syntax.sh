#!/bin/bash
# Fix GNU ps syntax in .bashrc to POSIX-compatible syntax for macOS support

BASHRC="${HOME}/.bashrc"

if [[ -f "$BASHRC" ]] && grep -qF 'ps --no-header --pid=$PPID --format=comm' "$BASHRC"; then
  echo "  Updating .bashrc: ps command to POSIX syntax"
  sed -i.bak 's/ps --no-header --pid=\$PPID --format=comm/ps -p $PPID -o comm=/' "$BASHRC"
  rm -f "$BASHRC.bak"
else
  echo "  .bashrc already up to date"
fi
