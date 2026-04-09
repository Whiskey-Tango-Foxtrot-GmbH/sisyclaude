---
name: activate
description: Activate SisyClaude as the default Claude Code orchestrator by injecting its instructions into the user's global CLAUDE.md. Backs up existing CLAUDE.md if present.
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob
argument-hint:
---

Activate SisyClaude as the default Claude Code orchestrator. Follow these steps exactly:

## Step 1: Check if already activated

Check if `~/.claude/CLAUDE.md` exists and already contains the SisyClaude marker:

```bash
grep -q "SisyClaude orchestrator - installed by /sisyclaude:activate" ~/.claude/CLAUDE.md 2>/dev/null && echo "ALREADY_ACTIVE" || echo "NOT_ACTIVE"
```

If `ALREADY_ACTIVE`, tell the user SisyClaude is already activated and stop. Do not back up or overwrite.

## Step 2: Check for conflicting plugins

Check if the `superpowers` plugin (from `claude-plugins-official`) is installed by looking for its SessionStart hook in settings:

```bash
grep -r "superpowers" ~/.claude/settings.json ~/.claude/settings.local.json 2>/dev/null | head -5
```

Also check if a `using-superpowers` skill or `superpowers` hook exists in the project-level settings:

```bash
grep -r "superpowers" .claude/settings.json .claude/settings.local.json 2>/dev/null | head -5
```

If **any match is found**, warn the user:

> **Warning: Conflicting plugin detected.**
>
> The `superpowers` plugin (from `claude-plugins-official`) uses aggressive SessionStart hooks that override SisyClaude's Phase 0 intent classification. When both are active, Claude will skip the think-first, delegate-first behavior and jump straight to action.
>
> **Options:**
> 1. **Disable superpowers hooks** (recommended) — I'll comment out the superpowers SessionStart hook in your settings so it doesn't inject conflicting instructions. You can re-enable it with `/sisyclaude:deactivate`.
> 2. **Continue anyway** — Keep both active, but expect degraded SisyClaude behavior.
> 3. **Abort** — Stop activation.

If the user chooses option 1, disable the superpowers SessionStart hook by reading the relevant settings file (global or project), removing or commenting out the hook entry that references `superpowers`, and writing the file back. Also create a marker file so deactivation knows to restore it:

```bash
echo "disabled_by_sisyclaude" > ~/.claude/.superpowers_disabled
```

If the user chooses option 3, stop. Do not proceed with activation.

## Step 3: Check for existing CLAUDE.md

```bash
test -f ~/.claude/CLAUDE.md && echo "EXISTS" || echo "NOT_FOUND"
```

## Step 4: Backup if it exists

If the file exists, create a timestamped backup:

```bash
cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.backup.$(date +%Y%m%d_%H%M%S)
```

Tell the user the backup path.

## Step 5: Read the Sisyphus agent definition

Read the sisyphus agent file from the plugin:

```
${CLAUDE_SKILL_DIR}/../../agents/sisyphus.md
```

## Step 6: Write CLAUDE.md

Create `~/.claude/CLAUDE.md` with the sisyphus agent content, but:
- **Strip the YAML frontmatter** (the `---` block with name, description, tools, model, color)
- **Keep everything else** (all the behavioral instructions from `<Role>` onward)
- **Prepend a header comment** so the user knows where it came from:

```markdown
<!-- SisyClaude orchestrator - installed by /sisyclaude:activate -->
<!-- Original CLAUDE.md backed up. Run /sisyclaude:deactivate to restore. -->
```

If the user already had content in their CLAUDE.md that they want to preserve (non-sisyclaude content), append a section break and the original content below the sisyphus instructions so nothing is lost.

## Step 7: Confirm

Tell the user:
- SisyClaude is now the default orchestrator
- Where the backup is (if one was made)
- They can restore their original with `/sisyclaude:deactivate`
