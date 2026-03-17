Legendary shell configuration for Zsh. Based on [omarchy-zsh](https://github.com/omacom-io/omarchy-zsh) by [Ryan Hughes](https://github.com/ryanhughes).

## What's different from omarchy-zsh?

- **Distro-agnostic** — no pacman, no `/usr/share/`. Clone it anywhere, works on Arch, Fedora, Ubuntu, macOS, etc.
- **Zsh plugins via git clone** — syntax highlighting, autosuggestions, completions, and fzf-tab with no plugin manager or system packages required
- **Enhanced tmux functions** — `tdl`, `tdlm`, and `tsl` from [Omarchy](https://github.com/omacom-io/omarchy) for dev layouts and swarm panes
- **Tab completion that works** — `compinit` enabled with case-insensitive matching and fzf-tab integration

## Install

### Prerequisites

- **git** and **zsh**
- Optional but recommended: [fzf](https://github.com/junegunn/fzf), [starship](https://starship.rs), [zoxide](https://github.com/ajeetdsouza/zoxide), [eza](https://github.com/eza-community/eza)

<details>
<summary><strong>Linux</strong></summary>

Install prerequisites with your package manager, e.g.:

```bash
# Arch
sudo pacman -S zsh fzf starship zoxide eza

# Ubuntu/Debian
sudo apt install zsh fzf
# starship, zoxide, and eza — install via their official instructions
```

</details>

<details>
<summary><strong>macOS</strong></summary>

macOS ships with zsh. Install the optional tools via [Homebrew](https://brew.sh):

```bash
brew install fzf starship zoxide eza
```

</details>

### Install

```bash
curl -fsSL https://raw.githubusercontent.com/jzetterman/legendary-zsh/master/install.sh | bash
```

Restart your terminal to activate zsh.

## Update

Run the same install command — it detects an existing installation and updates instead:

```bash
curl -fsSL https://raw.githubusercontent.com/jzetterman/legendary-zsh/master/install.sh | bash
```

Or if you already have legendary-zsh on your PATH:

```bash
legendary-update
```

Updates pull the latest changes and run any pending migrations (e.g., updating your `~/.zshrc` or `~/.bashrc` when templates change).

## Architecture

```mermaid
graph LR
    zshrc[~/.zshrc] --> zoptions & plugins & tmux & all
    all --> envs & aliases & functions & inits
    plugins --> sh[syntax-highlighting] & as[autosuggestions] & comp[completions] & ft[fzf-tab]

    style zoptions fill:#68f,stroke:#333,color:#fff
    style plugins fill:#68f,stroke:#333,color:#fff
    style tmux fill:#68f,stroke:#333,color:#fff
```

## fzf Keybindings

- **Ctrl+Alt+F** - Search files/directories
- **Ctrl+Alt+L** - Search Git Log
- **Ctrl+R** - Search command history
- **Ctrl+T** - Search files in current directory
- **Ctrl+V** - Search Variables
- **Alt+C** - cd into selected directory

## Tmux Functions

- **`tdl <ai> [<ai2>]`** - Dev layout: editor (70%), AI pane (30%), terminal (15% bottom)
- **`tdlm <ai> [<ai2>]`** - Multi-project: one `tdl` window per subdirectory
- **`tsl <count> <cmd>`** - Swarm layout: tiled panes all running the same command
- **`t`** - Attach to existing tmux session or create a new one

## Customization

Add your own configuration at the bottom of `~/.zshrc` after the legendary-zsh loading.

## Uninstall

```bash
rm -rf ~/.local/share/legendary-zsh
```

Restore your shell config from backups (saved as `~/.zshrc.backup-*` and `~/.bashrc.backup-*`).

## Credits

Originally created by [Ryan Hughes](https://github.com/ryanhughes) as [omarchy-zsh](https://github.com/omacom-io/omarchy-zsh). Licensed under MIT.
