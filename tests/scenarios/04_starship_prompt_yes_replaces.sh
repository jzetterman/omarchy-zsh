#!/bin/bash
# With LEGENDARY_STARSHIP_REPLACE=yes, the existing starship.toml is backed up
# and replaced by legendary-zsh's template.
source "$(dirname "$0")/_lib.sh"

echo "== 04: Starship prompt 'yes' replaces with backup =="

# Arrange
mkdir -p "$HOME/.config"
printf '# user starship config\nadd_newline = false\n' > "$HOME/.config/starship.toml"
cp "$HOME/.config/starship.toml" /tmp/starship.snapshot

# Act
run_setup LEGENDARY_STARSHIP_REPLACE=yes

# Assert: file replaced (no longer matches user's); backup matches snapshot
assert_files_differ "$HOME/.config/starship.toml" /tmp/starship.snapshot
assert_file_not_contains "$HOME/.config/starship.toml" "user starship config"

latest_backup="$(ls -t "$HOME"/.config/starship.toml.backup-* 2>/dev/null | head -1)"
if [ -n "$latest_backup" ]; then
  _lz_report_pass "backup created: $(basename "$latest_backup")"
  assert_files_equal "$latest_backup" /tmp/starship.snapshot
else
  _lz_report_fail "no backup file found after replacement"
fi

test_done
