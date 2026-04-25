#!/bin/bash
# Shared helpers for the legendary-* bin scripts. Not meant to be executed;
# sourced near the top of each user-facing script after LEGENDARY_ZSH_HOME
# is set.

# Prompt the user y/N. Returns 0 (yes) / 1 (no). When LEGENDARY_NONINTERACTIVE
# is set, reads $1 as the override value — y/Y/yes/YES/1/true/TRUE counts as
# yes; anything else (including empty) counts as no. Otherwise prompts via
# gum when available, with a (y/N) read fallback.
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

# Install fastfetch via the OS's package manager. Returns 0 if fastfetch is
# on PATH afterward (already present or newly installed), non-zero on
# failure. On apt systems, enables 'universe' when needed and falls back to
# the upstream .deb release if the repos don't carry fastfetch at all
# (e.g., Ubuntu 24.04 LTS).
_install_fastfetch() {
  if command -v fastfetch &>/dev/null; then
    return 0
  fi

  echo "Installing fastfetch..."
  if [[ "$OSTYPE" == darwin* ]]; then
    brew install fastfetch || return 1
  elif command -v pacman &>/dev/null; then
    sudo pacman -S --needed --noconfirm fastfetch || return 1
  elif command -v apt-get &>/dev/null; then
    _install_fastfetch_apt || return 1
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y fastfetch || return 1
  else
    echo "Error: no supported package manager detected. Install fastfetch manually." >&2
    return 1
  fi

  # The package manager reported success, but double-check the binary is
  # actually on PATH before we tell the user fastfetch is ready.
  command -v fastfetch &>/dev/null
}

# Apt-specific install path: try apt (enabling 'universe' if needed) and
# fall back to the upstream .deb if the package isn't in any enabled repo.
# Ubuntu 24.04 LTS has no fastfetch package at all, for example.
_install_fastfetch_apt() {
  local apt_ok=false

  if apt-cache madison fastfetch 2>/dev/null | grep -q .; then
    sudo apt-get install -y fastfetch && apt_ok=true
  else
    echo "Enabling the 'universe' repository and refreshing apt..."
    if ! command -v add-apt-repository &>/dev/null; then
      sudo apt-get install -y -qq software-properties-common || return 1
    fi
    sudo add-apt-repository -y universe || return 1
    sudo apt-get update -qq || return 1
    if apt-cache madison fastfetch 2>/dev/null | grep -q .; then
      sudo apt-get install -y fastfetch && apt_ok=true
    fi
  fi

  if [ "$apt_ok" = true ]; then
    return 0
  fi

  echo "fastfetch not available via apt — fetching upstream .deb release..."
  local arch tmpfile
  arch="$(dpkg --print-architecture 2>/dev/null)" || return 1
  tmpfile="$(mktemp --suffix=.deb)"
  if ! curl -fsSL "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-${arch}.deb" -o "$tmpfile"; then
    rm -f "$tmpfile"
    return 1
  fi
  sudo dpkg -i "$tmpfile" || sudo apt-get install -f -y || { rm -f "$tmpfile"; return 1; }
  rm -f "$tmpfile"
  return 0
}
