---
name: deactivate
description: Deactivate SisyClaude by removing the `sisyclaude` shell alias and deleting ~/.claude/SISYCLAUDE_SYSTEM_PROMPT.md.
user-invocable: true
allowed-tools: Read, Edit, Bash
argument-hint:
---

Deactivate SisyClaude. The uninstall:

1. Removes the `sisyclaude` alias block from every shell rc file that contains it.
2. Deletes `~/.claude/SISYCLAUDE_SYSTEM_PROMPT.md`.

It does NOT touch `~/.claude/CLAUDE.md` (the new install does not patch it).

Follow these steps:

## Step 1: Verify SisyClaude is active

Check for either the system prompt file or the alias in any rc file:

```bash
found_file=0
found_alias=0
test -f ~/.claude/SISYCLAUDE_SYSTEM_PROMPT.md && found_file=1

for f in ~/.zshrc ~/.bashrc ~/.bash_profile ~/.profile ~/.config/fish/config.fish; do
  [ -f "$f" ] || continue
  grep -q "# >>> sisyclaude alias >>>" "$f" && found_alias=1
done

echo "file=$found_file alias=$found_alias"
```

If both are `0`, tell the user SisyClaude is not currently activated and stop.

If only one is present, proceed and clean up whatever remains.

## Step 2: Remove the alias from every rc file that has it

For each rc file containing the marker, strip the block between `# >>> sisyclaude alias >>>` and `# <<< sisyclaude alias <<<` (inclusive). Use `sed -i.bak` so a backup is left behind:

```bash
removed_from=()
for f in ~/.zshrc ~/.bashrc ~/.bash_profile ~/.profile ~/.config/fish/config.fish; do
  [ -f "$f" ] || continue
  if grep -q "# >>> sisyclaude alias >>>" "$f"; then
    sed -i.bak '/# >>> sisyclaude alias >>>/,/# <<< sisyclaude alias <<</d' "$f"
    removed_from+=("$f")
  fi
done
printf 'Removed alias block from: %s\n' "${removed_from[@]:-<none>}"
```

`sed -i.bak` is portable across macOS (BSD sed) and Linux (GNU sed) — both write the original to `<file>.bak`.

Tell the user which files were edited and that `.bak` siblings were created in case they want to inspect or revert.

## Step 3: Delete the system prompt file

```bash
if [ -f ~/.claude/SISYCLAUDE_SYSTEM_PROMPT.md ]; then
  rm -f ~/.claude/SISYCLAUDE_SYSTEM_PROMPT.md
  echo "Removed ~/.claude/SISYCLAUDE_SYSTEM_PROMPT.md"
else
  echo "No system prompt file to remove."
fi
```

## Step 4: Check for disabled superpowers plugin

```bash
test -f ~/.claude/.superpowers_disabled && echo "WAS_DISABLED" || echo "NOT_DISABLED"
```

If `WAS_DISABLED`, ask the user whether to re-enable `superpowers` hooks. The exact settings entry varies, so tell them to check `~/.claude/settings.json` or `.claude/settings.json` and restore the `SessionStart` hook manually.

Then remove the marker:

```bash
rm -f ~/.claude/.superpowers_disabled
```

## Step 5: Confirm

Tell the user:

- The `sisyclaude` alias has been removed from `<list of rc files>` (backups at `<file>.bak`).
- `~/.claude/SISYCLAUDE_SYSTEM_PROMPT.md` has been deleted (or note it was already absent).
- They must reload their shell (`source <rc file>` or open a new terminal) for the alias to disappear from the current session.
- `~/.claude/CLAUDE.md` was not touched — this version of the skill never modified it.
- Re-activate any time with `/sisyclaude:activate`.
