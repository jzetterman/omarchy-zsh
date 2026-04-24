#!/bin/bash
# Fix GNU ps syntax in ~/.bashrc to POSIX-compatible syntax for macOS support.
#
# This modifies a user dotfile, so it prompts before applying. In
# non-interactive mode it defaults to "don't apply" (preservation-safe);
# set LEGENDARY_MIGRATE_APPLY=yes to opt in.

BASHRC="${HOME}/.bashrc"

if [[ ! -f "$BASHRC" ]] || ! grep -qF 'ps --no-header --pid=$PPID --format=comm' "$BASHRC"; then
  echo "  .bashrc already up to date"
  exit 0
fi

# Inline mirror of bin/legendary-*'s _lz_confirm — migrations run as standalone
# bash subprocesses and can't source the helper from the bin scripts.
_lz_confirm() {
  if [ -n "$LEGENDARY_NONINTERACTIVE" ]; then
    case "$1" in
      y|Y|yes|YES|1|true|TRUE) return 0 ;;
      *) return 1 ;;
    esac
  fi
  if command -v gum &>/dev/null; then
    gum confirm ""
  else
    printf "(y/N) "
    read -r reply
    [[ "$reply" =~ ^[Yy] ]]
  fi
}

echo "  Found legacy ps syntax in ~/.bashrc (incompatible with macOS):"
echo "    - old: ps --no-header --pid=\$PPID --format=comm"
echo "    - new: ps -p \$PPID -o comm="
echo "  Apply this fix?"

if ! _lz_confirm "$LEGENDARY_MIGRATE_APPLY"; then
  echo "  Skipped. Your ~/.bashrc is unchanged."
  exit 0
fi

sed -i.bak 's/ps --no-header --pid=\$PPID --format=comm/ps -p $PPID -o comm=/' "$BASHRC"
rm -f "$BASHRC.bak"
echo "  ~/.bashrc updated."
