#!/bin/bash
# Verify that ~/.config/legendary-zsh/paths supports all three expansion
# forms documented (and an undocumented-but-working fourth): leading ~,
# $HOME, ${HOME}, and a literal absolute path. The shell/envs loop reads
# each line, expands it, and prepends to PATH if the directory exists.
source "$(dirname "$0")/_lib.sh"

echo "== 23: paths file supports ~, \$HOME, \${HOME}, and literal forms =="

run_setup

# Create the directories first — _lz_prepend skips entries whose target
# doesn't exist on disk.
mkdir -p \
  "$HOME/dir-tilde" \
  "$HOME/dir-dollar" \
  "$HOME/dir-brace" \
  "$HOME/dir-literal"

# Write all four forms to the paths file. The single-quoted heredoc
# preserves the literal '$' and '~' characters so they hit shell/envs the
# way they would if a user had typed them.
mkdir -p "$HOME/.config/legendary-zsh"
cat > "$HOME/.config/legendary-zsh/paths" <<'EOF'
~/dir-tilde
$HOME/dir-dollar
${HOME}/dir-brace
EOF
# The literal absolute path needs $HOME expanded by the shell at write time.
echo "$HOME/dir-literal" >> "$HOME/.config/legendary-zsh/paths"

# Pull PATH from a fresh interactive zsh.
new_path="$(zsh -i -c 'echo $PATH' 2>/dev/null)"

for d in dir-tilde dir-dollar dir-brace dir-literal; do
  case ":$new_path:" in
    *":$HOME/$d:"*) _lz_report_pass "$d on PATH" ;;
    *) _lz_report_fail "$d NOT on PATH (got: $new_path)" ;;
  esac
done

test_done
