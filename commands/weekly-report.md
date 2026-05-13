Generate a weekly cross-repo activity report for one or more developers. Surfaces work that company dashboards (DX, internal metrics) miss because they only count the primary repo.

Target: $ARGUMENTS  (GitHub usernames, comma-separated, or a single user. Default: current `gh auth` user.)

## When to use

- Weekly status to a manager or contractor lead
- Defending against a "throughput is low" reading from a single-repo dashboard
- Sprint retrospective with full picture (PRs + reviews + non-code work)

## Steps

### 1. Parse the input

Get list of GitHub usernames. Default to one week ending today (Sunday-to-Saturday or Monday-to-Friday — pick consistent local week).

Optional flags in `$ARGUMENTS`:
- `--start YYYY-MM-DD`
- `--end YYYY-MM-DD`
- `--repos owner1/repo1,owner2/repo2` (filter to specific repos)
- `--include-jira` (also pull Jira tickets if Atlassian MCP is configured)

### 2. Pull PR data per user

For each user, run:

```bash
gh search prs --author <user> --limit 200 \
  --json number,title,state,createdAt,closedAt,repository,isDraft
```

Filter in code to the date window. Bucket into:
- **Created in window** (any state)
- **Merged in window**
- **Closed (not merged) in window**
- **Open at end of window**

### 3. Pull review data per user

For each user:

```bash
gh search prs --reviewed-by <user> --limit 100 \
  --json number,title,author,createdAt,updatedAt,repository
```

Filter to PRs touched (updated) within the window.

For each reviewed PR, count inline review comments authored by the user during the window:

```bash
gh api repos/<repo>/pulls/<number>/comments --paginate \
  --jq '[.[] | select(.user.login == "<user>") | select(.created_at >= "<start>" and .created_at <= "<end>")] | length'
```

### 4. Pull Jira tickets (if --include-jira)

Use the Atlassian MCP or the Jira REST API to fetch tickets the user touched in the window:

```
JQL: assignee = "<user>" AND updated >= "<start>" AND updated <= "<end>"
```

Group by status: In Progress, Development Complete, Pending Approval, Done, Blocked.

### 5. Detect cross-repo work

The whole point of this command is to surface work outside the "main" repo. Calculate per user:
- Number of merged PRs in primary repo (the one with most activity)
- Number of merged PRs across all other repos
- Reviews split: primary repo vs. cross-repo

Make this explicit in the output.

### 6. Detect "invisible" work patterns

Tag any of:
- **Closed-not-merged PRs**: investigate the most recent comment to detect "redirected", "superseded", "ticket cancelled". These count as work delivered (decision made) even if no code shipped.
- **Tickets resolved without a PR**: Jira ticket status transitioned to Done but no PR linked → operational/research/coordination work.
- **Confluence / CR / docs work**: not auto-detectable; ask the user to add manually if relevant ("Did you publish any docs or CRs this week?").

### 7. Compute per-PR cycle times

For merged PRs only:
- Median open-to-merged time
- List the longest 3 with reasons (best-guess from labels, comments, or "ask user to annotate")

This counters cycle-time complaints like "2 weeks average" by showing it's skewed by 2–3 outliers.

### 8. Assemble the report

```markdown
# Weekly report — week of <start> to <end>

## Summary table

| Person | Tickets | PRs created | PRs merged | PRs reviewed | Inline comments |
| --- | --- | --- | --- | --- | --- |
| <user>  | N | N | N | N | N |
| ... | | | | | |
| **Total** | N | N | N | N | N |

## Per-person detail

### <user>

**Active tickets (N)**:
- TICKET-123 — <summary> — <status>
- ...

**PRs merged (N)**:
- #N | <repo> | <title> | <cycle time>
- ...

**PRs open at end of week (N)**:
- ...

**Reviews delivered**: N PRs reviewed across <list of repos>. N inline comments. Notable catches: <list flagged-as-bug-found-during-review if detectable>.

**Why not rotating to other tasks (if relevant)**:
- Tickets in active states already (X tickets)
- Sequential dependency: Ticket A blocks Ticket B
- Operational/coordination work consumed bandwidth (X tickets)

### <next user>
...

## Cross-repo work detected

Work outside the primary repo that company dashboards may miss:
- N PRs merged in <other repos>
- N reviews on cross-repo PRs

## Other deliverables (manual entry)

- Confluence docs: <list, ask user>
- Change Requests authored: <list, ask user>
- Production cutovers without code: <list, ask user>
```

### 9. Output a copy-paste-ready summary for Slack / email

Below the full report, also produce a 200–400 word summary block clearly labeled `<<<COPY FOR SLACK / EMAIL>>>` that the user can paste directly into a manager DM or status email.

## Tone rules

- **No defensive language.** Don't say "we tried but...", "as much as we could...", "despite the obstacles...". State facts.
- **No fabricated numbers.** Every count comes from `gh` or Jira data; if you can't fetch it, mark it `<!-- VERIFY -->`.
- **Roles, not blame.** When explaining why a PR took long, attribute to "release window", "external dependency", "tech-lead redirect" — not "person X delayed it".
- Cycle-time outliers should be explained, not buried.
- Reviews count as real output. Don't relegate them to a footnote.
