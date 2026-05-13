#!/usr/bin/env bash
# Mechanical uninstall for /sisyclaude:deactivate.
# Strips the alias block from every rc file that contains it (using sed -i.bak
# for portability between BSD and GNU sed) and deletes the system prompt file.
#
# Output: line-oriented key=value.
#   removed_from=<space-separated rc paths, empty if none>
#   prompt_file=removed|already_absent

set -u

system_prompt="$HOME/.claude/SISYCLAUDE_SYSTEM_PROMPT.md"

removed_from=()
for f in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile" "$HOME/.config/fish/config.fish"; do
  [ -f "$f" ] || continue
  if grep -q "# >>> sisyclaude alias >>>" "$f"; then
    sed -i.bak '/# >>> sisyclaude alias >>>/,/# <<< sisyclaude alias <<</d' "$f"
    removed_from+=("$f")
  fi
done
echo "removed_from=${removed_from[*]:-}"

if [ -f "$system_prompt" ]; then
  rm -f "$system_prompt"
  echo "prompt_file=removed"
else
  echo "prompt_file=already_absent"
fi
