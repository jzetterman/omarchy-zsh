# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

legendary-zsh is a cross-platform zsh configuration framework. It installs shell plugins, dotfiles, aliases, functions, and tool integrations for zsh. Supports macOS (brew), Arch (pacman), Ubuntu/Debian (apt), and Fedora (dnf).

## Architecture

### Install & Update Flow

- **`install.sh`** — curl|bash entry point. Clones repo to `~/.local/share/legendary-zsh`, then runs `legendary-install-deps` and `legendary-setup-zsh`.
- **`bin/legendary-setup-zsh`** — First-time setup: clones zsh plugins, deploys `~/.zshrc` (preserving user customizations below the marker), deploys `~/.inputrc` only if absent, prompts before replacing `~/.config/starship.toml`, marks all migrations as run.
- **`bin/legendary-update`** — User-facing update: `git pull --ff-only`, runs migrations, installs new deps, re-offers fastfetch.
- **`bin/legendary-migrate`** — Runs pending `migrations/*.sh` files, tracks completed ones in `~/.local/state/legendary-zsh/migrations/`.
- **`bin/legendary-install-deps`** — Installs missing system dependencies (git, zsh, fzf, starship, zoxide, eza, gum) with OS-appropriate package managers.

### Shell Sourcing Chain

`templates/zshrc` → `~/.zshrc`:
```
shell/zoptions → shell/plugins → compinit → shell/tmux → shell/all
                                                           ├─ shell/envs
                                                           ├─ shell/aliases
                                                           ├─ shell/functions
                                                           └─ shell/inits
```

legendary-zsh does not manage `~/.bashrc`. Users who want the aliases, functions, and tool integrations in bash can add `source ~/.local/share/legendary-zsh/shell/all` to their own `~/.bashrc`.

### Key Paths

- **Install dir**: `~/.local/share/legendary-zsh`
- **State/markers**: `~/.local/state/legendary-zsh/` (migration tracking, `fastfetch-prompted`)
- **Plugins**: `~/.local/share/legendary-zsh/plugins/` (git-cloned, not checked in)

## Conventions

- **Scripts in `bin/`** are executable, prefixed `legendary-*`. Shell config files in `shell/` are sourced, never executed directly.
- **All aliases/inits guard on `command -v`** — nothing breaks if a tool is missing.
- **OS detection** pattern: check `$OSTYPE` for macOS, then `command -v pacman/apt-get/dnf` for Linux distros.
- **Idempotent**: every script is safe to run multiple times.
- **Backups**: setup creates timestamped backups of `~/.zshrc` (always) and `~/.config/starship.toml` (when replacing) before overwriting.
- **Migrations**: numbered `YYYYMMDD_description.sh` files in `migrations/`. Fresh installs skip all existing migrations. The migrate script uses `set -e`.
- **Migrations that touch user dotfiles must prompt**: any migration modifying paths under `~/` must confirm before applying. Inline the same `_lz_confirm` helper as the bin scripts (migrations run as standalone bash subprocesses and can't source a shared helper). In non-interactive mode the default is "don't apply" (preservation-safe); `LEGENDARY_MIGRATE_APPLY=yes` opts in. Exit 0 on both apply and decline paths — `legendary-migrate` will mark the migration done and move on either way.
- **State markers**: one-time prompts (fastfetch, starship, chsh) use touch files in `~/.local/state/legendary-zsh/` to avoid re-prompting.
- **In-file markers**: blocks legendary-zsh appends to user dotfiles (currently the fastfetch snippet) are wrapped in `# legendary-zsh:<name>-start` / `# legendary-zsh:<name>-end` comments so they can be removed cleanly with a `sed` range-delete. New appended blocks should follow the same convention.
- **Non-interactive mode**: when `$LEGENDARY_NONINTERACTIVE` is set, every prompt skips interactive input and defaults to a preservation-safe "no" (don't change shell, don't replace starship, don't enable fastfetch, don't proceed with uninstall). Per-prompt overrides: `LEGENDARY_STARSHIP_REPLACE`, `LEGENDARY_CHSH`, `LEGENDARY_FASTFETCH`, `LEGENDARY_UNINSTALL_CONFIRM` (set to `yes` to opt in). All three `bin/legendary-*` scripts that prompt define a `_lz_confirm <override_value>` helper near the top of the file.
- **Testing**: container-based integration tests live in `tests/`. `tests/run.sh [distro...]` builds a Docker image per distro (arch, ubuntu, fedora) and runs every scenario in `tests/scenarios/`. Scenarios source `tests/scenarios/_lib.sh`, which sources `tests/assert.sh` and auto-resets `$HOME`. CI runs the same script on every push and PR via `.github/workflows/test.yml`.
