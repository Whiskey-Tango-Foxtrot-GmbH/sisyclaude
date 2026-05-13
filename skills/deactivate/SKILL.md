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

The mechanical work lives in adjacent scripts; this file orchestrates and handles user prompts.

| File | Purpose |
|---|---|
| `check.sh` | Diagnoses current state (prompt file, alias rc files, superpowers marker) |
| `uninstall.sh` | Strips the alias block from every rc file and deletes the prompt file |

## Step 1: Read current state

```bash
bash "${CLAUDE_SKILL_DIR}/check.sh"
```

Parse the `key=value` output. Keys: `prompt_file`, `alias_in`, `superpowers_marker`.

If `prompt_file=absent` **and** `alias_in` is empty, SisyClaude is not currently activated. Tell the user and stop.

If only one is present, continue — the uninstall script will clean up whatever remains.

## Step 2: Run the uninstall

```bash
bash "${CLAUDE_SKILL_DIR}/uninstall.sh"
```

Parse the output: `removed_from` (space-separated rc paths, possibly empty), `prompt_file` (`removed` or `already_absent`).

The script uses `sed -i.bak` so each edited rc file gets a `<file>.bak` sibling in case the user wants to inspect or revert.

## Step 3: Handle the superpowers marker

If `superpowers_marker=present` from Step 1, ask the user whether to re-enable `superpowers` hooks. The exact settings entry varies, so tell them to check `~/.claude/settings.json` or `.claude/settings.json` and restore the `SessionStart` hook manually.

Then remove the marker:

```bash
rm -f ~/.claude/.superpowers_disabled
```

## Step 4: Confirm

Tell the user:

- The `sisyclaude` alias was removed from `<list from removed_from>` (backups at `<file>.bak`). If the list was empty, say nothing was removed from any rc.
- `~/.claude/SISYCLAUDE_SYSTEM_PROMPT.md` was deleted (or note it was already absent).
- They must reload their shell (`source <rc file>` or open a new terminal) for the alias to disappear from the current session.
- `~/.claude/CLAUDE.md` was not touched — this version of the skill never modified it.
- Re-activate any time with `/sisyclaude:activate`.
