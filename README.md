# ai-dev-setup v2.0

Automated developer environment setup for engineers who use Claude Code + Windsurf/Cursor. One script to configure git conventions, install AI slash commands, and enforce team standards across all your projects.

## Quick Start

```bash
git clone https://github.com/FabricioZAGA/ai-dev-setup.git
cd ai-dev-setup
chmod +x install.sh
./install.sh
```

---

## Commands

After setup, these slash commands are available in Claude Code in any project:

### Code Review

| Command | What it does |
|---------|-------------|
| `/review-comment <PR>` | Reviews a PR diff and posts inline GitHub comments. Checks existing discussions first so it never duplicates. Writes like a teammate, not a bot. |
| `/review-fix <PR>` | Reads open review comments on your own PR, fixes the valid ones, pushes back with reasoning on incorrect ones, and commits. |
| `/pr-respond <PR>` | Drafts and posts replies to all open comments on a PR — questions, concerns, or requests for context. |

### Implementation

| Command | What it does |
|---------|-------------|
| `/jira-to-windsurf <ticket>` | Analyzes a Jira ticket + codebase and generates a ready-to-run prompt for Windsurf Cascade. Saves to `.cascade-task.md` and copies to clipboard. |
| `/branch-from-jira <ticket>` | Creates a properly named branch and writes a `PLAN.md` with impact zones and implementation steps. |
| `/split-pr [ticket]` | Splits staged changes into a feature PR (impl only) and a tests PR (tests only), both properly linked. |
| `/test-gen <file or function>` | Generates tests following the project's exact patterns, fixtures, and mock style. |

### Planning & Delivery

| Command | What it does |
|---------|-------------|
| `/cr <ticket>` | Generates a complete Change Request in Jira (all sections + Risk Assessment) from a ticket ID. |
| `/risk-assessment <ticket or PR>` | Generates a standalone Risk Assessment table for a Change Request. |
| `/standup [days]` | Generates a standup summary from git, PRs, and Jira activity. Defaults to 1 day; use 3 for Monday. |
| `/plan-doc <topic or ticket>` | Generates a structured multi-phase design / implementation plan: TL;DR, scope, subtasks, risk register, rollback, comm plan, FAQ. Use it for work that spans multiple phases or stakeholders. |
| `/triage-ticket <ticket>` | Deep research before you touch code: pulls the ticket, traces the codebase, flags hidden complexity, estimates scope, and proposes subtasks. Use when a ticket is large or vague. |
| `/weekly-report [@user1,@user2]` | Cross-repo activity report for one or more devs over a week. Surfaces work that single-repo dashboards miss (PRs in other repos, reviews, non-code deliverables). |

### Operations

| Command | What it does |
|---------|-------------|
| `/pre-flight-check <PR or service>` | Read-only checklist before merging or deploying. Verifies approvals, CI, conflicts, open comments, and (for deploys) backups, rollback plan, stakeholders. |
| `/merge-pr <PR>` | Pre-merge guard then merge. Checks approvals, CI, open threads. Picks the right merge strategy. Reports post-merge state and what to watch next. |
| `/validate-deploy <service or URL>` | Captures a baseline of the target (TLS cert, HTTP headers, status), waits for a deploy, then re-checks and produces a side-by-side diff. Use for cert rotations, config swaps, image promotions. |
| `/cve-fix <CVE-id or package>` | End-to-end remediation for a vulnerable dependency: identifies usage, picks safe version, drafts the bump PR with blast-radius assessment, and a CR-ready summary. |

### Documentation

| Command | What it does |
|---------|-------------|
| `/confluence-doc <markdown file>` | Publishes a local markdown file to Confluence as a live page (or updates an existing one). Handles tables, code blocks, links. Outputs the live URL. |

### Environments

| Command | What it does |
|---------|-------------|
| `/opdev create <name>` | Creates a new opdev environment on your current branch. Auto-rebases if behind master. |
| `/opdev sync <name>` | Syncs local server code to an opdev. |
| `/opdev logs <name>` | Prints the docker logs commands for the rq worker or web container. |
| `/opdev shell <name>` | Prints the SSM + docker exec commands to get a python shell inside the opdev. |
| `/opdev restart <name>` | Reboots the opdev EC2 instance and re-syncs code. |
| `/opdev delete <name>` | Deletes the opdev stack (asks for confirmation first). |

---

## Git Hooks

Three hooks are installed globally (apply to all repos) or per-project.

### `commit-msg` — Conventional Commits
Validates every commit against `type(scope): subject` format.

```bash
git commit -m "feat(auth): add OAuth2 login"   # ✓
git commit -m "updated stuff"                   # ✗ blocked
```

Allowed types: `feat`, `fix`, `test`, `refactor`, `chore`, `docs`, `ci`, `perf`, `build`, `revert`

### `pre-push` — Branch naming
Validates branch names against your configured pattern before push.

Default pattern: `{username}/{ticket}/{description}`

```bash
fzacarias/FIRE-3772/mvip-agent-emit-change   # ✓
my-feature                                   # ✗ blocked
```

### `prepare-commit-msg` — Strip AI co-author attribution
Automatically removes `Co-Authored-By:` lines from any AI assistant (Claude, Copilot, etc.) so commits only show the real author.

---

## Install Flags

```bash
./install.sh              # Full interactive setup
./install.sh --check      # Check tool dependencies only
./install.sh --configure  # Re-run configuration wizard
./install.sh --commands   # Install/update Claude commands only
./install.sh --hooks      # Install git hooks in the current repo
./install.sh --update     # Pull latest and reinstall commands
./install.sh --claude-md  # Generate a CLAUDE.md template in the current project
```

---

## Configuration

Preferences are saved to `~/.dev-setup-config`. Edit directly or re-run `./install.sh --configure`.

```bash
GIT_NAME="Fabricio Zacarias"
GIT_EMAIL="fabricio@example.com"
GITHUB_USER="FabricioZAGA"
AI_EDITOR="windsurf"
USE_JIRA="true"
JIRA_WORKSPACE="yourteam.atlassian.net"
BRANCH_PATTERN="{username}/{ticket}/{description}"
USE_CONVENTIONAL_COMMITS="true"
```

---

## Requirements

**Required:** git ≥ 2.30, gh CLI ≥ 2.0, Node.js ≥ 18, Claude Code

**Optional:** Windsurf or Cursor, Jira Atlassian MCP, Google Workspace MCP, jq

---

## Adding Your Own Commands

Commands are plain `.md` files in `commands/`. The filename becomes the slash command name.

```bash
cat > commands/my-command.md << 'EOF'
Do something useful with: $ARGUMENTS
## Steps
1. ...
EOF
./install.sh --commands
```

---

## Updating

```bash
cd ai-dev-setup
./install.sh --update
```

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

*Built by [@FabricioZAGA](https://github.com/FabricioZAGA)*
