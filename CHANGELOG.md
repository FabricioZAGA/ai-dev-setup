# Changelog

## v2.1.0 — 2026-05-13

Additive release. No breaking changes. All v2.0 commands and hooks continue to work exactly as before.

### New commands

**Planning & Delivery**
- `/plan-doc <topic or ticket>` — Generates a structured multi-phase design / implementation plan with TL;DR, subtasks, risk register, rollback, comm plan, and FAQ. For work that spans multiple stakeholders or phases.
- `/triage-ticket <ticket>` — Deep ticket research before opening a PR. Pulls the ticket, traces the codebase, flags hidden complexity, estimates scope, proposes subtasks. Use when a ticket is large or vague.
- `/weekly-report [@user1,@user2]` — Cross-repo activity report for one or more devs over a week. Surfaces PRs in non-primary repos, reviews, inline comments, and non-code deliverables that single-repo dashboards miss.

**Operations**
- `/pre-flight-check <PR or service>` — Read-only checklist before merging or deploying: approvals, CI, conflicts, comments, backups, rollback plan, stakeholders.
- `/merge-pr <PR>` — Pre-merge guard then merge. Picks the right strategy, reports post-merge state and what to watch.
- `/validate-deploy <service or URL>` — Captures a baseline (TLS cert, HTTP headers, status), waits for a deploy, then re-checks. Produces a side-by-side diff. For cert rotations, config swaps, image promotions.
- `/cve-fix <CVE-id or package>` — End-to-end CVE remediation: identifies usage, picks safe version, drafts the bump PR with blast-radius assessment, and a CR-ready summary.

**Documentation**
- `/confluence-doc <markdown file>` — Publishes a local markdown file to Confluence as a live page (or updates an existing one). Handles tables, code blocks, links.

### Documentation
- README updated with new "Operations" and "Documentation" sections grouping the new commands by purpose.

---

## v2.0.0 — 2026-04-23

### New commands
- `/split-pr` — splits staged changes into a feature PR (impl only) and a tests PR (tests only), with both properly linked and merge-order instructions
- `/opdev` — full opdev lifecycle management: create, sync, logs, shell, restart, delete. Auto-rebases if branch is behind master on create.
- `/pr-respond` — drafts and posts replies to all open comments on a PR (inline + top-level)

### Improved commands

**`/review-comment`**
- Now loads all existing review comments and discussions before posting — never duplicates a comment that's already been made
- If an issue is already covered by another reviewer's comment, skips it (or adds context as a reply instead)
- Rewrote tone rules: writes like a teammate, not a code review tool. No em dashes, no formal headers, short prose, contractions OK
- Added approve flow: if no real issues found (or all prior comments resolved), posts an approval with a genuine short message
- Added missing mock detection for Celery jobs and external calls in tests

**`/review-fix`**
- Replies now follow the same human tone rules (short, conversational, no em dashes)
- Varied reply openers so responses don't all start with "Fixed"

### New git hook
- `prepare-commit-msg` — strips `Co-Authored-By:` lines from AI assistants (Claude, Copilot, etc.) from every commit automatically. Installed globally.

### Documentation
- README rewritten as v2 with full command reference table, environment commands, and hook descriptions
- Added CHANGELOG

---

## v1.0.0 — 2026-02-01

Initial release.

### Commands
- `/review-comment` — inline PR review with code suggestions
- `/review-fix` — address review comments on your own PRs
- `/jira-to-windsurf` — generate Windsurf Cascade prompts from Jira tickets
- `/branch-from-jira` — create branches with proper naming from Jira tickets
- `/cr` — generate full Change Requests in Jira
- `/risk-assessment` — generate Risk Assessment tables for CRs
- `/standup` — daily standup from git + Jira + open PRs
- `/test-gen` — generate tests following project patterns

### Git hooks
- `commit-msg` — conventional commit format enforcement
- `pre-push` — branch naming pattern enforcement

### Setup
- Interactive `install.sh` with dependency checks, git config, and global hook installation
- `CLAUDE.md` template generator
