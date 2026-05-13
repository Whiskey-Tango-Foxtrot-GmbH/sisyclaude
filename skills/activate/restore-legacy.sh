#!/usr/bin/env bash
# Restores the oldest ~/.claude/CLAUDE.md.backup.* over ~/.claude/CLAUDE.md.
# Used when a legacy SisyClaude install patched CLAUDE.md and we want to undo it
# before running the new install (which doesn't touch CLAUDE.md).
#
# Output:
#   restored_from=<backup path>           # on success
#   no_backup                             # if nothing to restore from

set -u

oldest=$(ls -t "$HOME"/.claude/CLAUDE.md.backup.* 2>/dev/null | tail -1)

if [ -z "$oldest" ]; then
  echo "no_backup"
  exit 0
fi

cp "$oldest" "$HOME/.claude/CLAUDE.md"
echo "restored_from=$oldest"
