#!/bin/bash
# Running legendary-enable-fastfetch twice doesn't duplicate the block.
source "$(dirname "$0")/_lib.sh"

echo "== 11: enable-fastfetch is idempotent =="

# Arrange: fresh install, then enable once
stub_fastfetch
run_setup
bash "$LEGENDARY_ZSH_HOME/bin/legendary-enable-fastfetch" >/dev/null

# Sanity: exactly one start marker in zshrc
starts_after_first="$(grep -c 'legendary-zsh:fastfetch-start' "$HOME/.zshrc" 2>/dev/null || echo 0)"
[ "$starts_after_first" = "1" ] && _lz_report_pass "one start marker after first enable" \
  || _lz_report_fail "unexpected count after first enable: $starts_after_first"

# Act: enable again
bash "$LEGENDARY_ZSH_HOME/bin/legendary-enable-fastfetch"

# Assert: still exactly one start marker
starts_after_second="$(grep -c 'legendary-zsh:fastfetch-start' "$HOME/.zshrc" 2>/dev/null || echo 0)"
[ "$starts_after_second" = "1" ] && _lz_report_pass "still one start marker after second enable" \
  || _lz_report_fail "unexpected count after second enable: $starts_after_second"

test_done
