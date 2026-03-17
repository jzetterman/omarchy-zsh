# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

legendary-zsh is a cross-platform zsh configuration framework. It installs shell plugins, dotfiles, aliases, functions, and tool integrations for zsh (with bash fallback). Supports macOS (brew), Arch (pacman), Ubuntu/Debian (apt), and Fedora (dnf).

## Architecture

### Install & Update Flow

- **`install.sh`** — curl|bash entry point. Clones repo to `~/.local/share/legendary-zsh`, then runs `legendary-install-deps` and `legendary-setup-zsh`.
- **`bin/legendary-setup-zsh`** — First-time setup: clones zsh plugins, deploys templates to `~/.zshrc`/`~/.bashrc`/`~/.inputrc`, marks all migrations as run.
- **`bin/legendary-update`** — User-facing update: `git pull --ff-only`, runs migrations, installs new deps, re-offers fastfetch.
- **`bin/legendary-migrate`** — Runs pending `migrations/*.sh` files, tracks completed ones in `~/.local/state/legendary-zsh/migrations/`.
- **`bin/legendary-install-deps`** — Installs missing system dependencies (git, zsh, fzf, starship, zoxide, eza, gum) with OS-appropriate package managers.

### Shell Sourcing Chain

**Zsh** (`templates/zshrc` → `~/.zshrc`):
```
shell/zoptions → shell/plugins → compinit → shell/tmux → shell/all
                                                           ├─ shell/envs
                                                           ├─ shell/aliases
                                                           ├─ shell/functions
                                                           └─ shell/inits
```

**Bash** (`templates/bashrc` → `~/.bashrc`): auto-launches zsh if available, otherwise sources `shell/all`.

`shell/all` is the shared entry point for both shells. `shell/zoptions`, `shell/plugins`, and `shell/tmux` are zsh-only.

### Key Paths

- **Install dir**: `~/.local/share/legendary-zsh`
- **State/markers**: `~/.local/state/legendary-zsh/` (migration tracking, `fastfetch-prompted`)
- **Plugins**: `~/.local/share/legendary-zsh/plugins/` (git-cloned, not checked in)

## Conventions

- **Scripts in `bin/`** are executable, prefixed `legendary-*`. Shell config files in `shell/` are sourced, never executed directly.
- **All aliases/inits guard on `command -v`** — nothing breaks if a tool is missing.
- **OS detection** pattern: check `$OSTYPE` for macOS, then `command -v pacman/apt-get/dnf` for Linux distros.
- **Idempotent**: every script is safe to run multiple times.
- **Backups**: setup creates timestamped backups of existing dotfiles before overwriting.
- **Migrations**: numbered `YYYYMMDD_description.sh` files in `migrations/`. Fresh installs skip all existing migrations. The migrate script uses `set -e`.
- **State markers**: one-time prompts (like fastfetch) use touch files in `~/.local/state/legendary-zsh/` to avoid re-prompting.
- **`install.sh` is wrapped in `main()`** to prevent curl|bash stdin consumption by subprocesses.
