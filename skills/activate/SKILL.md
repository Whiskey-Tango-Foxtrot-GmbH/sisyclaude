---
name: activate
description: Activate SisyClaude by writing its system prompt to ~/.claude/SISYCLAUDE_SYSTEM_PROMPT.md and adding a `sisyclaude` shell alias that loads it via `claude --system-prompt-file` (replaces the default Claude Code system prompt for that session).
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob
argument-hint:
---

Activate SisyClaude. The install does NOT patch `~/.claude/CLAUDE.md`. Instead it:

1. Writes the Sisyphus instructions to `~/.claude/SISYCLAUDE_SYSTEM_PROMPT.md`.
2. Adds a `sisyclaude` shell alias that runs `claude --system-prompt-file "$HOME/.claude/SISYCLAUDE_SYSTEM_PROMPT.md"`. This **replaces** Claude Code's default system prompt for `sisyclaude` sessions — Sisyphus is the entire system prompt, not an addition.

The mechanical work lives in adjacent scripts; this file orchestrates and handles user prompts.

| File | Purpose |
|---|---|
| `check.sh` | Diagnoses current state (prompt file, alias, legacy install, superpowers) |
| `restore-legacy.sh` | Restores the oldest `CLAUDE.md.backup.*` if a legacy install is present |
| `install.sh` | Copies `system-prompt.md` to `~/.claude/SISYCLAUDE_SYSTEM_PROMPT.md`, detects shell, appends alias |
| `system-prompt.md` | The full Sisyphus system prompt (loaded at top level — Sisyphus is not a sub-agent, since the Agent tool cannot nest) |

## Step 1: Read current state

```bash
bash "${CLAUDE_SKILL_DIR}/check.sh"
```

Parse the `key=value` output. Keys: `prompt_file`, `alias_in`, `legacy_claude_md`, `superpowers`.

If `prompt_file=present` **and** `alias_in` is non-empty, SisyClaude is already activated. Tell the user and stop. Mention `/sisyclaude:deactivate` to remove it.

If only one of the two is present, continue — the install script is idempotent and will fill in whatever's missing.

## Step 2: Offer to clean up a legacy install

If `legacy_claude_md=present`, tell the user:

> A legacy SisyClaude install is patched into `~/.claude/CLAUDE.md`. The new install does not touch that file. To avoid duplicate instructions, I can restore the oldest backup (`~/.claude/CLAUDE.md.backup.*`) to your CLAUDE.md before proceeding. Continue with restore? (recommended)

If yes:

```bash
bash "${CLAUDE_SKILL_DIR}/restore-legacy.sh"
```

If the script prints `no_backup`, ask whether to delete `~/.claude/CLAUDE.md` outright or leave it as-is (duplicate instructions will be active during `sisyclaude` sessions but harmless).

## Step 3: Handle superpowers conflict

If `superpowers=present`, warn the user:

> **Warning: Conflicting plugin detected.**
>
> The `superpowers` plugin uses aggressive `SessionStart` hooks that inject instructions overriding SisyClaude's Phase 0 intent classification. With both active inside a `sisyclaude` session, Claude may skip the think-first, delegate-first behavior.
>
> **Options:**
> 1. **Disable superpowers hooks** (recommended) — comment out the `SessionStart` hook entries referencing `superpowers`. Re-enable manually after `/sisyclaude:deactivate`.
> 2. **Continue anyway** — keep both active, expect degraded behavior.
> 3. **Abort** — stop activation.

If option 1, remove or comment out the superpowers `SessionStart` hook entries in the relevant settings file, then mark it so deactivation knows:

```bash
echo "disabled_by_sisyclaude" > ~/.claude/.superpowers_disabled
```

If option 3, stop.

## Step 4: Run the install

```bash
bash "${CLAUDE_SKILL_DIR}/install.sh"
```

Parse the output keys: `wrote`, `shell`, `rc`, `style`, `alias_status`.

If the script exits non-zero or prints an `ERROR:` line on stderr, surface it to the user and stop — do not pretend the install succeeded.

If `shell=unknown` (i.e. `$SHELL` was unrecognised and the script fell back to `~/.profile`), tell the user what shell was detected and ask if `~/.profile` is correct or if they want a different rc file. If different, do the alias append manually using the same marker block style.

## Step 5: Confirm — and tell the user what to do NEXT

Make the next-action steps prominent. The current Claude Code session does **not** pick up the new alias or system prompt — Sisyphus only takes effect in a fresh `sisyclaude` session. Spell this out:

> **Install complete.**
>
> - System prompt written to `<value of wrote=>`.
> - Alias `sisyclaude` was `<added | already present>` in `<value of rc=>`.
>
> **Next steps — do these now to activate Sisyphus:**
>
> 1. **Exit this Claude Code session** (`/exit`, Ctrl-D, or close the window). The current session was started with plain `claude`, so the new alias and system prompt are not loaded here.
> 2. **Open a new terminal**, or reload your shell so the alias is on PATH:
>    - bash/zsh: `source <value of rc=>`
>    - fish: `source <value of rc=>`
> 3. **Launch the new session** by running `sisyclaude` (instead of `claude`). That session loads Sisyphus via `--system-prompt-file`, replacing Claude Code's default system prompt for that session.
>
> Plain `claude` is left untouched — vanilla behaviour is preserved for any non-SisyClaude work. Run `/sisyclaude:deactivate` inside a Claude Code session any time to remove the alias and the system prompt file.
