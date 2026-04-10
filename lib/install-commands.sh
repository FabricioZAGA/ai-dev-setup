#!/usr/bin/env bash
# Install Claude Code slash commands to ~/.claude/commands/

source "$(dirname "$0")/colors.sh"

COMMANDS_DIR="$HOME/.claude/commands"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="$SCRIPT_DIR/commands"

install_commands() {
  step "Installing Claude Code commands"

  if ! command -v claude &>/dev/null; then
    warn "Claude Code not found — skipping command installation."
    warn "Install Claude Code first: npm install -g @anthropic-ai/claude-code"
    return 1
  fi

  mkdir -p "$COMMANDS_DIR"

  local installed=0
  local skipped=0

  for cmd_file in "$SOURCE_DIR"/*.md; do
    local name
    name=$(basename "$cmd_file")

    if [[ -f "$COMMANDS_DIR/$name" ]]; then
      # Check if content differs
      if diff -q "$cmd_file" "$COMMANDS_DIR/$name" &>/dev/null; then
        dim "      /${name%.md} — already up to date"
        ((skipped++))
      else
        cp "$cmd_file" "$COMMANDS_DIR/$name"
        ok "Updated /${name%.md}"
        ((installed++))
      fi
    else
      cp "$cmd_file" "$COMMANDS_DIR/$name"
      ok "Installed /${name%.md}"
      ((installed++))
    fi
  done

  echo ""
  info "$installed command(s) installed/updated, $skipped already up to date"
  info "Use them in Claude Code: /review-comment, /review-fix, /risk-assessment, /jira-to-windsurf, ..."
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_commands
fi
