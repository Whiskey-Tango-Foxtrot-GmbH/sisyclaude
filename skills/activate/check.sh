#!/usr/bin/env bash
# Diagnostic for /sisyclaude:activate.
# Prints line-oriented key=value state so SKILL.md can branch on the result.
#
# Keys:
#   prompt_file=present|absent
#   alias_in=<space-separated rc file paths, empty if none>
#   legacy_claude_md=present|absent
#   superpowers=present|absent

set -u

system_prompt="$HOME/.claude/SISYCLAUDE_SYSTEM_PROMPT.md"
legacy_claude_md="$HOME/.claude/CLAUDE.md"

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

if grep -qE "Sisy(phus|Claude) orchestrator - installed by /sisy(phus|claude):activate" "$legacy_claude_md" 2>/dev/null; then
  echo "legacy_claude_md=present"
else
  echo "legacy_claude_md=absent"
fi

if grep -rq "superpowers" "$HOME/.claude/settings.json" "$HOME/.claude/settings.local.json" 2>/dev/null \
   || grep -rq "superpowers" ".claude/settings.json" ".claude/settings.local.json" 2>/dev/null; then
  echo "superpowers=present"
else
  echo "superpowers=absent"
fi
