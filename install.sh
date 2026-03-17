#!/bin/bash

LEGENDARY_ZSH_HOME="${HOME}/.local/share/legendary-zsh"

# --- Dependency installation ---

install_deps() {
  local missing=()

  for cmd in git zsh fzf starship zoxide eza gum; do
    command -v "$cmd" &>/dev/null || missing+=("$cmd")
  done

  if [ ${#missing[@]} -eq 0 ]; then
    echo "All dependencies already installed."
    return
  fi

  echo "Missing: ${missing[*]}"

  if [[ "$OSTYPE" == darwin* ]]; then
    if ! command -v brew &>/dev/null; then
      echo "Error: Homebrew is required on macOS. Install it from https://brew.sh"
      exit 1
    fi
    # macOS ships with git and zsh, but handle them just in case
    echo "Installing dependencies via Homebrew..."
    brew install "${missing[@]}"

  elif command -v pacman &>/dev/null; then
    echo "Installing dependencies via pacman..."
    sudo pacman -S --needed --noconfirm "${missing[@]}"

  elif command -v apt-get &>/dev/null; then
    # starship, zoxide, and eza aren't in default apt repos — install those separately
    local apt_pkgs=()
    local manual_pkgs=()

    for pkg in "${missing[@]}"; do
      case "$pkg" in
        starship|zoxide|eza) manual_pkgs+=("$pkg") ;;
        *) apt_pkgs+=("$pkg") ;;
      esac
    done

    if [ ${#apt_pkgs[@]} -gt 0 ]; then
      echo "Installing ${apt_pkgs[*]} via apt..."
      sudo apt-get update -qq
      sudo apt-get install -y "${apt_pkgs[@]}"
    fi

    for pkg in "${manual_pkgs[@]}"; do
      case "$pkg" in
        starship)
          echo "Installing starship..."
          curl -sS https://starship.rs/install.sh | sh -s -- -y
          ;;
        zoxide)
          echo "Installing zoxide..."
          curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
          ;;
        eza)
          echo "Installing eza..."
          sudo mkdir -p /etc/apt/keyrings
          wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
          echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
          sudo apt-get update -qq
          sudo apt-get install -y eza
          ;;
      esac
    done

  elif command -v dnf &>/dev/null; then
    echo "Installing dependencies via dnf..."
    local dnf_pkgs=()
    local manual_pkgs=()

    for pkg in "${missing[@]}"; do
      case "$pkg" in
        starship) manual_pkgs+=("$pkg") ;;
        *) dnf_pkgs+=("$pkg") ;;
      esac
    done

    if [ ${#dnf_pkgs[@]} -gt 0 ]; then
      sudo dnf install -y "${dnf_pkgs[@]}"
    fi

    for pkg in "${manual_pkgs[@]}"; do
      case "$pkg" in
        starship)
          echo "Installing starship..."
          curl -sS https://starship.rs/install.sh | sh -s -- -y
          ;;
      esac
    done

  else
    echo "Error: Could not detect package manager. Install these manually: ${missing[*]}"
    exit 1
  fi
}

install_pkg() {
  local pkg="$1"
  if command -v "$pkg" &>/dev/null; then
    return
  fi

  echo "Installing $pkg..."
  if [[ "$OSTYPE" == darwin* ]]; then
    brew install "$pkg"
  elif command -v pacman &>/dev/null; then
    sudo pacman -S --needed --noconfirm "$pkg"
  elif command -v apt-get &>/dev/null; then
    sudo apt-get install -y "$pkg"
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y "$pkg"
  fi
}

prompt_fastfetch() {
  local state_dir="${HOME}/.local/state/legendary-zsh"
  mkdir -p "$state_dir"

  # Already asked or already configured — don't ask again
  if [ -f "$state_dir/fastfetch-prompted" ]; then return; fi
  if grep -qF 'fastfetch' "${HOME}/.zshrc" 2>/dev/null; then return; fi

  echo ""
  echo "Would you like to install fastfetch and run it when new terminal sessions start?"
  local wants_fastfetch=false
  if command -v gum &>/dev/null; then
    gum confirm "" < /dev/tty 2>/dev/tty && wants_fastfetch=true || true
  fi

  if [ "$wants_fastfetch" = true ]; then
    install_pkg fastfetch
    if ! grep -qF 'fastfetch' "${HOME}/.zshrc"; then
      printf '\n# Show system info on new terminal sessions\ncommand -v fastfetch &>/dev/null && fastfetch\n' >> "${HOME}/.zshrc"
    fi
    echo "fastfetch enabled!"
  fi

  touch "$state_dir/fastfetch-prompted"
}

# --- Main ---

if [ -d "$LEGENDARY_ZSH_HOME/.git" ]; then
  echo "Existing installation found. Updating..."
  install_deps
  "$LEGENDARY_ZSH_HOME/bin/legendary-update"
elif [ -d "$LEGENDARY_ZSH_HOME" ]; then
  echo "Existing directory found but not a valid install. Re-installing..."
  install_deps
  rm -rf "$LEGENDARY_ZSH_HOME"
  git clone https://github.com/jzetterman/legendary-zsh.git "$LEGENDARY_ZSH_HOME" || { echo "Error: git clone failed"; exit 1; }
  "$LEGENDARY_ZSH_HOME/bin/legendary-setup-zsh" || { echo "Error: setup failed"; exit 1; }
else
  echo "Installing legendary-zsh..."
  install_deps
  git clone https://github.com/jzetterman/legendary-zsh.git "$LEGENDARY_ZSH_HOME" || { echo "Error: git clone failed"; exit 1; }
  "$LEGENDARY_ZSH_HOME/bin/legendary-setup-zsh" || { echo "Error: setup failed"; exit 1; }
fi

prompt_fastfetch
