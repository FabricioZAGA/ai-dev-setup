#!/usr/bin/env bash
# Dependency checker — validates required and optional tools
# Returns 0 if all required tools are present, 1 if any are missing.

source "$(dirname "$0")/colors.sh"

MISSING_REQUIRED=0
MISSING_OPTIONAL=()

check_tool() {
  local name="$1"
  local cmd="$2"
  local required="$3"   # "required" or "optional"
  local install_hint="$4"

  if command -v "$cmd" &>/dev/null; then
    local version
    version=$("$cmd" --version 2>/dev/null | head -1 || echo "installed")
    ok "${name}: ${DIM}${version}${NC}"
  else
    if [[ "$required" == "required" ]]; then
      fail "${name}: ${RED}not found${NC}"
      if [[ -n "$install_hint" ]]; then
        dim "      Install: $install_hint"
      fi
      MISSING_REQUIRED=1
    else
      warn "${name}: not found (optional)"
      MISSING_OPTIONAL+=("$name")
      if [[ -n "$install_hint" ]]; then
        dim "      Install: $install_hint"
      fi
    fi
  fi
}

check_claude() {
  if command -v claude &>/dev/null; then
    local version
    version=$(claude --version 2>/dev/null | head -1 || echo "installed")
    ok "Claude Code: ${DIM}${version}${NC}"
  else
    fail "Claude Code: ${RED}not found${NC}"
    dim "      Install: npm install -g @anthropic-ai/claude-code"
    dim "      Or visit: https://claude.ai/code"
    MISSING_REQUIRED=1
  fi
}

check_editor() {
  local found_editor=false
  if command -v windsurf &>/dev/null; then
    ok "Windsurf: ${DIM}$(windsurf --version 2>/dev/null | head -1)${NC}"
    found_editor=true
    DETECTED_EDITOR="windsurf"
  fi
  if command -v cursor &>/dev/null; then
    ok "Cursor: ${DIM}$(cursor --version 2>/dev/null | head -1)${NC}"
    found_editor=true
    DETECTED_EDITOR="${DETECTED_EDITOR:-cursor}"
  fi
  if command -v code &>/dev/null; then
    ok "VS Code: ${DIM}$(code --version 2>/dev/null | head -1)${NC}"
    found_editor=true
    DETECTED_EDITOR="${DETECTED_EDITOR:-code}"
  fi
  if [[ "$found_editor" == false ]]; then
    warn "No AI editor found (Windsurf, Cursor, or VS Code)"
    dim "      Windsurf: https://windsurf.com"
    dim "      Cursor:   https://cursor.com"
    MISSING_OPTIONAL+=("AI editor")
  fi
}

run_checks() {
  step "Checking required tools"
  check_tool "git"      "git"    "required" "https://git-scm.com"
  check_tool "gh CLI"   "gh"     "required" "brew install gh  OR  https://cli.github.com"
  check_tool "Node.js"  "node"   "required" "brew install node  OR  https://nodejs.org"
  check_claude

  step "Checking optional tools"
  check_tool "jq"       "jq"     "optional" "brew install jq"
  check_tool "Python 3" "python3" "optional" "brew install python"
  check_editor

  echo ""
  if [[ $MISSING_REQUIRED -eq 1 ]]; then
    fail "Some required tools are missing. Install them and re-run setup."
    return 1
  fi

  if [[ ${#MISSING_OPTIONAL[@]} -gt 0 ]]; then
    warn "Optional tools missing: ${MISSING_OPTIONAL[*]}"
    warn "Some commands may have limited functionality."
  fi

  ok "All required tools present."
  return 0
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  run_checks
fi
