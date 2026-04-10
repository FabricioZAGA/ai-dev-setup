# ai-dev-setup

Automated developer environment setup for engineers who use Claude Code + Windsurf/Cursor. One script to configure git conventions, install AI slash commands, and enforce team standards across all your projects.

## What it does

```
./install.sh
```

1. **Validates your tools** — git, gh CLI, Claude Code, Node.js, Windsurf/Cursor
2. **Asks your preferences** — branch naming pattern, conventional commits, Jira workspace, AI editor
3. **Configures git globally** — name, email, sensible defaults
4. **Installs Claude Code slash commands** — ready to use in any project instantly
5. **Sets up git hooks** — enforces conventional commits and branch naming on every push

---

## Quick Start

```bash
git clone https://github.com/FabricioZAGA/ai-dev-setup.git
cd ai-dev-setup
chmod +x install.sh
./install.sh
```

---

## Commands Installed

After setup, these slash commands are available in Claude Code (`claude`) in any project:

| Command | What it does |
|---------|-------------|
| `/cr <ticket>` | Generates a complete Change Request in Jira (all sections + Risk Assessment) from a ticket ID |
| `/review-comment <PR>` | Reviews a PR diff and posts inline GitHub comments with code suggestions |
| `/review-fix <PR>` | Reads review comments on your own PR, fixes valid ones, pushes back on incorrect ones |
| `/risk-assessment <ticket or PR>` | Generates a standalone Risk Assessment table for a Change Request |
| `/jira-to-windsurf <ticket>` | Analyzes a Jira ticket and generates a prompt for Windsurf Cascade |
| `/branch-from-jira <ticket>` | Creates a properly-named branch and writes a PLAN.md |
| `/standup [days]` | Generates a standup summary from git, PRs, and Jira activity |
| `/test-gen <file or function>` | Generates tests following the project's exact patterns |

---

## Flags

```bash
./install.sh              # Full interactive setup (first time)
./install.sh --check      # Check tool dependencies only
./install.sh --configure  # Re-run configuration wizard
./install.sh --commands   # Install/update Claude commands only
./install.sh --hooks      # Install git hooks in the current repo
./install.sh --update     # Pull latest version and reinstall commands
./install.sh --claude-md  # Generate a CLAUDE.md template in the current project
```

---

## Git Hooks

### `commit-msg` — Conventional Commits

Validates every commit message against the format:

```
type(scope): subject
```

**Allowed types:** `feat`, `fix`, `test`, `refactor`, `chore`, `docs`, `ci`, `perf`, `build`, `revert`

```bash
git commit -m "feat(auth): add OAuth2 login"      # ✓
git commit -m "fix(api): handle null response"     # ✓
git commit -m "updated stuff"                      # ✗ blocked
```

### `pre-push` — Branch naming

Validates branch names against your configured pattern before push.

Default pattern: `{username}/{ticket}/{description}`

```bash
# ✓ Valid
fzacarias/FIRE-3772/mvip-agent-emit-change

# ✗ Blocked
my-feature
update-stuff
```

To install hooks in a project:
```bash
cd your-project
/path/to/ai-dev-setup/install.sh --hooks
```

To install globally (applies to all new repos):
- Run `install.sh` and answer **yes** to "Install git hooks globally"

---

## Configuration

Preferences are saved to `~/.dev-setup-config`. Edit directly or re-run:

```bash
./install.sh --configure
```

Example config:

```bash
GIT_NAME="Fabricio Zacarias"
GIT_EMAIL="fabricio@example.com"
GITHUB_USER="FabricioZAGA"
AI_EDITOR="windsurf"
USE_JIRA="true"
JIRA_WORKSPACE="yourteam.atlassian.net"
BRANCH_PATTERN="{username}/{ticket}/{description}"
USE_CONVENTIONAL_COMMITS="true"
COMMIT_TYPES="feat|fix|test|refactor|chore|docs|ci|perf|build|revert"
```

---

## CLAUDE.md Generator

Every project should have a `CLAUDE.md` file that tells Claude Code about the project's conventions, tech stack, and useful commands. Generate a template:

```bash
cd your-project
/path/to/ai-dev-setup/install.sh --claude-md
```

---

## Requirements

**Required:**
- git ≥ 2.30
- [gh CLI](https://cli.github.com) ≥ 2.0
- [Node.js](https://nodejs.org) ≥ 18
- [Claude Code](https://claude.ai/code) — `npm install -g @anthropic-ai/claude-code`

**Optional (some commands need these):**
- [Windsurf](https://windsurf.com) or [Cursor](https://cursor.com)
- Jira access + Atlassian MCP configured in Claude Code
- Google Workspace MCP (for auto-creating Google Docs from risk assessments)
- jq

---

## Adding Your Own Commands

Commands are plain `.md` files in `commands/`. The filename becomes the slash command name.

```bash
# Create a new command
cat > commands/my-command.md << 'EOF'
Do something useful with: $ARGUMENTS

## Steps
1. ...
EOF

# Install it
./install.sh --commands
```

Use `/my-command argument` in Claude Code.

---

## Updating

```bash
cd ai-dev-setup
./install.sh --update
```

This pulls the latest version and reinstalls all commands.

---

*Built by [@FabricioZAGA](https://github.com/FabricioZAGA)*
