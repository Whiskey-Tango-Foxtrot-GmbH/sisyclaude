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

## Step 2: Check for existing CLAUDE.md

```bash
test -f ~/.claude/CLAUDE.md && echo "EXISTS" || echo "NOT_FOUND"
```

## Step 3: Backup if it exists

If the file exists, create a timestamped backup:

```bash
cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.backup.$(date +%Y%m%d_%H%M%S)
```

Tell the user the backup path.

## Step 4: Read the Sisyphus agent definition

Read the sisyphus agent file from the plugin:

```
${CLAUDE_SKILL_DIR}/../../agents/sisyphus.md
```

## Step 5: Write CLAUDE.md

Create `~/.claude/CLAUDE.md` with the sisyphus agent content, but:
- **Strip the YAML frontmatter** (the `---` block with name, description, tools, model, color)
- **Keep everything else** (all the behavioral instructions from `<Role>` onward)
- **Prepend a header comment** so the user knows where it came from:

```markdown
<!-- SisyClaude orchestrator - installed by /sisyclaude:activate -->
<!-- Original CLAUDE.md backed up. Run /sisyclaude:deactivate to restore. -->
```

If the user already had content in their CLAUDE.md that they want to preserve (non-sisyclaude content), append a section break and the original content below the sisyphus instructions so nothing is lost.

## Step 6: Confirm

Tell the user:
- SisyClaude is now the default orchestrator
- Where the backup is (if one was made)
- They can restore their original with `/sisyclaude:deactivate`
