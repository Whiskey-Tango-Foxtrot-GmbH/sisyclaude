---
name: deactivate
description: Deactivate SisyClaude by restoring the user's original CLAUDE.md from backup.
user-invocable: true
allowed-tools: Read, Bash
argument-hint:
---

Deactivate SisyClaude and restore the user's original CLAUDE.md. Follow these steps:

## Step 1: Verify SisyClaude is active

```bash
grep -q "SisyClaude orchestrator - installed by /sisyclaude:activate" ~/.claude/CLAUDE.md 2>/dev/null && echo "ACTIVE" || echo "NOT_ACTIVE"
```

If `NOT_ACTIVE`, tell the user SisyClaude is not currently activated and stop.

## Step 2: Find the oldest backup (the original)

Find the **oldest** backup — this is the user's original CLAUDE.md from before the first activation, not a backup of an already-activated state:

```bash
ls -t ~/.claude/CLAUDE.md.backup.* 2>/dev/null | tail -1
```

If no backup exists, tell the user there's nothing to restore — just delete `~/.claude/CLAUDE.md` if they want to remove SisyClaude.

## Step 3: Restore the backup

```bash
cp <oldest_backup> ~/.claude/CLAUDE.md
```

## Step 4: Check for disabled superpowers plugin

Check if SisyClaude previously disabled the superpowers plugin:

```bash
test -f ~/.claude/.superpowers_disabled && echo "WAS_DISABLED" || echo "NOT_DISABLED"
```

If `WAS_DISABLED`, ask the user:

> The `superpowers` plugin was disabled during SisyClaude activation. Would you like to re-enable it?

If yes, the user will need to manually re-enable the superpowers hooks in their settings (since the exact hook configuration varies). Tell them where to look (`~/.claude/settings.json` or `.claude/settings.json`).

Either way, clean up the marker:

```bash
rm -f ~/.claude/.superpowers_disabled
```

## Step 5: Confirm

Tell the user:
- Their original CLAUDE.md has been restored
- The backup files are still there if they need them
- Whether superpowers was re-enabled or still disabled
- They can re-activate with `/sisyclaude:activate`
