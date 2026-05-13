#!/usr/bin/env bash
# Diagnostic for /sisyclaude:deactivate.
# Prints line-oriented key=value state.
#
# Keys:
#   prompt_file=present|absent
#   alias_in=<space-separated rc file paths, empty if none>
#   superpowers_marker=present|absent

set -u

system_prompt="$HOME/.claude/SISYCLAUDE_SYSTEM_PROMPT.md"

if [ -f "$system_prompt" ]; then
  echo "prompt_file=present"
else
  echo "prompt_file=absent"
fi

alias_rcs=()
for f in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile" "$HOME/.config/fish/config.fish"; do
  [ -f "$f" ] || continue
  if grep -q "# >>> sisyclaude alias >>>" "$f"; then
    alias_rcs+=("$f")
  fi
done
echo "alias_in=${alias_rcs[*]:-}"

if [ -f "$HOME/.claude/.superpowers_disabled" ]; then
  echo "superpowers_marker=present"
else
  echo "superpowers_marker=absent"
fi
