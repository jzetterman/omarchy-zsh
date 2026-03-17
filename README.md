Legendary shell configuration for Zsh. Works on **macOS** and **Linux** (Arch, Ubuntu/Debian, Fedora). Based on [omarchy-zsh](https://github.com/omacom-io/omarchy-zsh) by [Ryan Hughes](https://github.com/ryanhughes).

## What's different from omarchy-zsh?

- **Cross-platform** — works on macOS and Linux. No pacman, no `/usr/share/`. Clone it anywhere.
- **Zsh plugins via git clone** — syntax highlighting, autosuggestions, completions, and fzf-tab with no plugin manager or system packages required
- **Enhanced tmux functions** — `tdl`, `tdlm`, and `tsl` from [Omarchy](https://github.com/basecamp/omarchy) for dev layouts and swarm panes
- **Tab completion that works** — `compinit` enabled with case-insensitive matching and fzf-tab integration

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/jzetterman/legendary-zsh/master/install.sh | bash
```

The installer automatically detects your OS and installs all dependencies:

| | Package Manager | Packages |
|---|---|---|
| **macOS** | Homebrew | git, zsh, fzf, starship, zoxide, eza, gum |
| **Arch** | pacman | git, zsh, fzf, starship, zoxide, eza, gum |
| **Ubuntu/Debian** | apt + official installers | git, zsh, fzf, starship, zoxide, eza, gum |
| **Fedora** | dnf + official installers | git, zsh, fzf, starship, zoxide, eza, gum |

During installation you'll be prompted to optionally install [fastfetch](https://github.com/fastfetch-cli/fastfetch) to show system info when new terminal sessions start.

Restart your terminal to activate zsh.

## Update

After installation, `legendary-update` is available on your PATH. Run it any time to get the latest changes:

```bash
legendary-update
```

This will:
- Pull the latest changes from the repository
- Run any pending migrations (e.g. config fixes for new OS support)
- Install any newly added dependencies

## Disable fastfetch

If you enabled fastfetch during installation and want to turn it off:

```bash
legendary-disable-fastfetch
```

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
