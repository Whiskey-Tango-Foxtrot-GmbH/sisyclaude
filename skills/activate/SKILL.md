---
name: activate
description: Activate SisyClaude by writing its system prompt to ~/.claude/SISYCLAUDE_SYSTEM_PROMPT.md and adding a `sisyclaude` shell alias that loads it via `claude --append-system-prompt-file`.
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob
argument-hint:
---

Activate SisyClaude. The install does NOT patch `~/.claude/CLAUDE.md`. Instead it:

1. Writes the Sisyphus instructions to `~/.claude/SISYCLAUDE_SYSTEM_PROMPT.md`.
2. Adds a `sisyclaude` shell alias that runs `claude --append-system-prompt-file "$HOME/.claude/SISYCLAUDE_SYSTEM_PROMPT.md"`.

Follow these steps exactly.

## Step 1: Check if already activated

```bash
test -f ~/.claude/SISYCLAUDE_SYSTEM_PROMPT.md && echo "FILE_PRESENT" || echo "FILE_MISSING"
```

Then check the rc files for an existing alias block:

```bash
for f in ~/.zshrc ~/.bashrc ~/.bash_profile ~/.config/fish/config.fish; do
  [ -f "$f" ] && grep -q "# >>> sisyclaude alias >>>" "$f" && echo "ALIAS_IN $f"
done
```

If both the system prompt file exists AND the alias is present in at least one rc file, tell the user SisyClaude is already activated and stop. Mention `/sisyclaude:deactivate` to remove it.

If only one of the two is present, proceed — the missing piece will be added in the steps below.

## Step 2: Detect and offer to clean up legacy install

Older versions of this skill patched `~/.claude/CLAUDE.md` directly. Detect and offer to clean up:

```bash
grep -qE "Sisy(phus|Claude) orchestrator - installed by /sisy(phus|claude):activate" ~/.claude/CLAUDE.md 2>/dev/null && echo "LEGACY_PRESENT" || echo "NO_LEGACY"
```

If `LEGACY_PRESENT`, tell the user:

> A legacy SisyClaude install is patched into `~/.claude/CLAUDE.md`. The new install does not touch that file. To avoid duplicate instructions, I can restore the oldest backup (`~/.claude/CLAUDE.md.backup.*`) to your CLAUDE.md before proceeding. Continue with restore? (recommended)

If the user agrees, find the oldest backup and restore it:

```bash
oldest=$(ls -t ~/.claude/CLAUDE.md.backup.* 2>/dev/null | tail -1)
[ -n "$oldest" ] && cp "$oldest" ~/.claude/CLAUDE.md && echo "Restored from $oldest"
```

If no backup exists, ask whether to delete `~/.claude/CLAUDE.md` outright or leave it as-is (duplicate instructions will be active during `sisyclaude` sessions but harmless).

## Step 3: Check for conflicting plugins (superpowers)

```bash
grep -r "superpowers" ~/.claude/settings.json ~/.claude/settings.local.json 2>/dev/null | head -5
grep -r "superpowers" .claude/settings.json .claude/settings.local.json 2>/dev/null | head -5
```

If any match is found, warn the user:

> **Warning: Conflicting plugin detected.**
>
> The `superpowers` plugin uses aggressive `SessionStart` hooks that inject instructions overriding SisyClaude's Phase 0 intent classification. With both active inside a `sisyclaude` session, Claude may skip the think-first, delegate-first behavior.
>
> **Options:**
> 1. **Disable superpowers hooks** (recommended) — comment out the `SessionStart` hook entries referencing `superpowers`. Re-enable manually after `/sisyclaude:deactivate`.
> 2. **Continue anyway** — keep both active, expect degraded behavior.
> 3. **Abort** — stop activation.

If option 1, remove or comment out the superpowers `SessionStart` hook entries in the relevant settings file, then mark it:

```bash
echo "disabled_by_sisyclaude" > ~/.claude/.superpowers_disabled
```

If option 3, stop.

## Step 4: Build the system prompt content

Read the sisyphus agent file from the plugin:

```
${CLAUDE_SKILL_DIR}/../../agents/sisyphus.md
```

Strip the YAML frontmatter (the leading `---` block with name/description/tools/model/color). Keep everything from `<Role>` onward.

Prepend this header so the source is obvious:

```markdown
<!-- SisyClaude system prompt - installed by /sisyclaude:activate -->
<!-- Loaded by the `sisyclaude` shell alias via `claude --append-system-prompt-file`. -->
<!-- Run /sisyclaude:deactivate to remove the alias and this file. -->
```

## Step 5: Write the system prompt file

Write the combined content to `~/.claude/SISYCLAUDE_SYSTEM_PROMPT.md`. Overwrite if present (the legacy-cleanup step above already handled CLAUDE.md).

## Step 6: Detect the user's shell and pick the rc file

Use `$SHELL` to detect, fall back to checking `~/.zshrc`/`~/.bashrc` presence:

```bash
shell_name=$(basename "${SHELL:-}")
uname_s=$(uname -s)

case "$shell_name" in
  zsh)
    rc="$HOME/.zshrc"
    style="posix"
    ;;
  bash)
    # macOS bash conventionally uses .bash_profile for login shells.
    if [ "$uname_s" = "Darwin" ] && [ -f "$HOME/.bash_profile" ]; then
      rc="$HOME/.bash_profile"
    elif [ -f "$HOME/.bashrc" ]; then
      rc="$HOME/.bashrc"
    elif [ "$uname_s" = "Darwin" ]; then
      rc="$HOME/.bash_profile"
    else
      rc="$HOME/.bashrc"
    fi
    style="posix"
    ;;
  fish)
    rc="$HOME/.config/fish/config.fish"
    mkdir -p "$(dirname "$rc")"
    style="fish"
    ;;
  *)
    # Unknown shell — ask the user which rc file to edit, or default to ~/.profile.
    rc="$HOME/.profile"
    style="posix"
    ;;
esac

echo "shell=$shell_name rc=$rc style=$style"
```

If the detected shell is unknown, tell the user what was detected and ask whether to write to `~/.profile` or a path they specify.

## Step 7: Append the alias block

Skip if the markers already exist in the chosen rc file:

```bash
grep -q "# >>> sisyclaude alias >>>" "$rc" 2>/dev/null && echo "ALREADY_HAS_ALIAS" || echo "NEEDS_ALIAS"
```

For POSIX shells (bash, zsh), append:

```
# >>> sisyclaude alias >>>
alias sisyclaude='claude --append-system-prompt-file "$HOME/.claude/SISYCLAUDE_SYSTEM_PROMPT.md"'
# <<< sisyclaude alias <<<
```

For fish, append (note fish's alias syntax — space-separated, double-quoted):

```
# >>> sisyclaude alias >>>
alias sisyclaude "claude --append-system-prompt-file \"$HOME/.claude/SISYCLAUDE_SYSTEM_PROMPT.md\""
# <<< sisyclaude alias <<<
```

Use `printf '...\n' >> "$rc"` or the Write tool to append — do NOT overwrite.

## Step 8: Confirm

Tell the user:

- System prompt written to `~/.claude/SISYCLAUDE_SYSTEM_PROMPT.md`.
- Alias `sisyclaude` added to `<rc file path>`.
- They must reload their shell to use it: `source <rc file>` (or open a new terminal; fish users: `source <rc file>` works too).
- Usage: run `sisyclaude` instead of `claude` to launch a session with the SisyClaude orchestrator instructions pre-loaded.
- Plain `claude` is untouched — vanilla behavior is preserved.
- Run `/sisyclaude:deactivate` (inside a Claude Code session) to remove the alias and the system prompt file.
