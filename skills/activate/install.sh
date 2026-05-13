#!/usr/bin/env bash
# Mechanical install for /sisyclaude:activate.
# Copies system-prompt.md to ~/.claude/SISYCLAUDE_SYSTEM_PROMPT.md,
# then appends the `sisyclaude` alias to the user's shell rc.
#
# Decisions that need user prompts (legacy cleanup, superpowers disable) are
# handled by SKILL.md BEFORE this script runs.
#
# Output: line-oriented key=value so SKILL.md can report back to the user.
#   wrote=<path to prompt file>
#   shell=<bash|zsh|fish|unknown>
#   rc=<path to rc file>
#   style=<posix|fish>
#   alias_status=added|already_present

set -eu

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_prompt="$here/system-prompt.md"
prompt_file="$HOME/.claude/SISYCLAUDE_SYSTEM_PROMPT.md"

[ -f "$source_prompt" ] || { echo "ERROR: missing $source_prompt" >&2; exit 1; }

mkdir -p "$(dirname "$prompt_file")"
cp "$source_prompt" "$prompt_file"
echo "wrote=$prompt_file"

shell_name="$(basename "${SHELL:-}")"
uname_s="$(uname -s)"

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
    rc="$HOME/.profile"
    style="posix"
    ;;
esac

echo "shell=$shell_name"
echo "rc=$rc"
echo "style=$style"

if [ -f "$rc" ] && grep -q "# >>> sisyclaude alias >>>" "$rc"; then
  echo "alias_status=already_present"
  exit 0
fi

if [ "$style" = "fish" ]; then
  cat >> "$rc" <<'EOF'

# >>> sisyclaude alias >>>
alias sisyclaude "claude --system-prompt-file \"$HOME/.claude/SISYCLAUDE_SYSTEM_PROMPT.md\""
# <<< sisyclaude alias <<<
EOF
else
  cat >> "$rc" <<'EOF'

# >>> sisyclaude alias >>>
alias sisyclaude='claude --system-prompt-file "$HOME/.claude/SISYCLAUDE_SYSTEM_PROMPT.md"'
# <<< sisyclaude alias <<<
EOF
fi

echo "alias_status=added"
