# Tests

Container-based integration tests for legendary-zsh. Each scenario runs in a fresh container per distro, exercising the install/uninstall flow with the `LEGENDARY_NONINTERACTIVE` env vars.

## Running

```bash
./tests/run.sh                        # all distros (arch, ubuntu, fedora)
./tests/run.sh arch                   # single distro
./tests/run.sh -s 01_fresh_install.sh # single scenario, all distros
```

Requires `podman` or `docker` on the host. Set `CONTAINER_CMD` to override the detected tool.

## Layout

```
tests/
├── docker/
│   ├── Dockerfile.arch
│   ├── Dockerfile.ubuntu
│   └── Dockerfile.fedora
├── scenarios/
│   ├── _lib.sh        # shared helpers, sourced by every scenario
│   ├── 01_fresh_install.sh
│   ├── 02_preserve_existing_inputrc.sh
│   ├── 03_starship_prompt_no_preserves.sh
│   ├── 04_starship_prompt_yes_replaces.sh
│   ├── 05_bashrc_untouched.sh
│   ├── 06_zshrc_user_content_preserved.sh
│   ├── 07_uninstall_clean.sh
│   └── 08_uninstall_preserves_user_starship.sh
├── assert.sh          # assertion helpers (sourced transitively via _lib.sh)
├── run.sh             # test runner
└── README.md
```

## Writing a scenario

```bash
#!/bin/bash
source "$(dirname "$0")/_lib.sh"

echo "== NN: <description> =="

# Arrange
printf '...\n' > "$HOME/.something"

# Act
run_setup                                 # or run_uninstall
# Pass env var overrides as args:
# run_setup LEGENDARY_STARSHIP_REPLACE=yes

# Assert
assert_file_exists "$HOME/.zshrc"
assert_file_contains "$HOME/.zshrc" "some-line"
assert_glob_empty "$HOME/.bashrc.backup-*"

test_done
```

The `test_done` call at the end prints a summary and sets the exit status.

## Assertions

| Helper | Checks |
|---|---|
| `assert_file_exists PATH` | Path exists (file or directory) |
| `assert_file_absent PATH` | Path does not exist |
| `assert_file_contains PATH PATTERN` | `grep -F` finds `PATTERN` in `PATH` |
| `assert_file_not_contains PATH PATTERN` | `PATTERN` not found in `PATH` |
| `assert_files_equal A B` | `cmp -s A B` succeeds |
| `assert_files_differ A B` | `cmp -s A B` fails |
| `assert_glob_empty GLOB` | No paths match the glob (quote the glob!) |

## How it works

The repo is mounted read-only at `/repo` inside each container. The `_lib.sh` helper copies it into `$LEGENDARY_ZSH_HOME` and pre-creates the plugin subdirs so `legendary-setup-zsh` skips its `git clone` calls — keeps tests fast and network-independent. Scenarios then run `legendary-setup-zsh` (or `-uninstall`) with `LEGENDARY_NONINTERACTIVE=1` and whatever overrides the scenario needs.

Images are built on demand by `run.sh` and cached by the container tool, so subsequent runs are fast.
