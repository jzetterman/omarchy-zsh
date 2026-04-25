#!/bin/bash
# legendary-update fetches new commits for the bundled zsh plugins. Without
# this, security patches and bug fixes never reach existing users — plugins
# were git-cloned at install time and otherwise never touched.
#
# Strategy: clone one of the real plugins, hard-reset it to an older commit,
# then run legendary-update and assert HEAD has advanced.
source "$(dirname "$0")/_lib.sh"

echo "== 21: legendary-update pulls bundled plugin updates =="

install_legendary_source

# The /repo bindmount carries the host's .git, which has an SSH remote URL
# (git@github.com:...). Test containers don't have ssh — switch to https so
# legendary-update's `git pull` works against the public GitHub repo. Also
# realign to master with upstream tracking, since the host may be on a
# feature branch with no upstream configured.
git -C "$LEGENDARY_ZSH_HOME" remote set-url origin \
  https://github.com/jzetterman/legendary-zsh.git
git -C "$LEGENDARY_ZSH_HOME" fetch --quiet origin master
git -C "$LEGENDARY_ZSH_HOME" checkout --quiet -B master origin/master

# install_legendary_source pre-creates empty plugin dirs. Replace one with
# a real clone so we have something to update.
plugin_dir="$LEGENDARY_ZSH_HOME/plugins/zsh-syntax-highlighting"
rm -rf "$plugin_dir"
if ! git clone --quiet --depth 5 \
    https://github.com/zsh-users/zsh-syntax-highlighting.git "$plugin_dir" 2>/dev/null; then
  _lz_report_fail "could not clone test plugin (network issue?)"
  test_done
  exit
fi

# Configure git in case the container has no global config (test envs).
git -C "$plugin_dir" config user.email test@example.com
git -C "$plugin_dir" config user.name test

# Reset to an older commit so legendary-update has something to pull
old_head="$(git -C "$plugin_dir" rev-parse HEAD~3 2>/dev/null)"
if [ -z "$old_head" ]; then
  _lz_report_fail "couldn't find HEAD~3"
  test_done
  exit
fi
git -C "$plugin_dir" reset --hard --quiet "$old_head"

# Sanity
[ "$(git -C "$plugin_dir" rev-parse HEAD)" = "$old_head" ] \
  && _lz_report_pass "plugin reset to older commit" \
  || _lz_report_fail "plugin reset failed"

# Act
LEGENDARY_NONINTERACTIVE=1 bash "$LEGENDARY_ZSH_HOME/bin/legendary-update" >/dev/null 2>&1

# Assert: HEAD has moved past the older commit
new_head="$(git -C "$plugin_dir" rev-parse HEAD)"
if [ "$new_head" != "$old_head" ]; then
  _lz_report_pass "plugin advanced past old HEAD"
else
  _lz_report_fail "plugin still at $old_head — update didn't pull"
fi

test_done
