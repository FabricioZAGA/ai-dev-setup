Take a Jira ticket (or any issue tracker), do deep research before you touch code, and produce a scoped breakdown so you don't open a PR for the wrong thing.

Ticket: $ARGUMENTS

## When to use

Before starting any ticket that:
- Is vague ("fix the leak")
- Mentions multiple systems
- Is large (epic-sized or unscoped)
- Has been open for weeks (likely needs re-scoping)
- You inherited from someone else

Skip this for clear, isolated bug fixes with a known fix.

## Steps

### 1. Fetch the ticket

Use the Atlassian MCP or `curl` with the user's API token to fetch:
- Title, description
- Acceptance criteria
- Status, priority, severity, assignee, reporter
- Linked tickets (parent epic, blockers, blocked-by, clones)
- Comments (full thread, especially newer ones — they often supersede the description)
- Linked PRs / branches

If the ticket has been updated within the past week, prefer the latest comments over the description for current scope.

### 2. Read the room

Specifically extract:
- **Real problem statement**: not always what the title says. Check comments for "actually what we want is..."
- **Stakeholders mentioned**: who has weighed in?
- **Decisions already made**: any "we agreed to..." in comments?
- **Constraints called out**: launch dates, customer deadlines, change-window restrictions
- **Prior attempts**: linked PRs that were closed without merge often carry the real context

### 3. Codebase research (don't fabricate)

For every system/table/service mentioned in the ticket:
- Find the source-of-truth file (`grep -rn "<name>"`)
- Read the surrounding 30–50 lines, not just the match
- Trace one full call path end-to-end
- Note pre-existing helpers that solve part of the problem (avoids duplication)

If the ticket mentions a bug or incident:
- Search git log for related fixes (`git log --all --grep "<keyword>"`)
- Check if there's already a partial fix or rollback in history

### 4. Detect hidden complexity

Specifically flag:
- **Cross-system effects** the ticket doesn't mention (events, downstream consumers, sync jobs, caches)
- **Pre-conditions** that must be true before fix can land
- **Reversibility risk** — DB migrations, removed enum values, deleted records
- **Breaking changes** for clients or downstream services

If you find something like this, it goes in the output as a "Hidden complexity" bullet.

### 5. Estimate scope honestly

Categorize the ticket:
- **Trivial** (≤ 1h): obvious one-liner
- **Small** (1–4h): single file, small test
- **Medium** (4–16h): multiple files, multiple tests, possibly a CR
- **Large** (16h+): multi-PR or multi-phase, needs design doc

If it's Large but filed as a single ticket: flag for split into sub-tasks.

### 6. Write the triage doc

Save to `<ticket-id>-triage.md` in the current directory:

```markdown
# <TICKET-ID> — Triage

## Real problem
<1–2 sentences, in plain language. NOT a copy of the ticket title.>

## What the ticket asks vs. what it should ask
| Stated | Real |
| --- | --- |
| <description summary> | <what the comments / context reveal> |

## Stakeholders
- <Role>: <expectation / decision they've made>

## Codebase entry points
- `path/to/file.py:123` — <function name> — <what it does>
- ...

## Prior work
- PR #N (closed, redirected because <reason>)
- Commit <SHA> (<msg>) — partial fix from <date>

## Hidden complexity
- <item 1>
- <item 2>

## Pre-conditions
- <thing that must be true before code lands>

## Proposed scope (estimate: <S/M/L>)
1. <Subtask>
2. <Subtask>
3. <Subtask>

If Large: recommend splitting into:
- TICKET-A: <chunk 1>
- TICKET-B: <chunk 2>

## Open questions for the requester
- <question 1>
- <question 2>

## Risk / reversibility
- <what's hard to undo>
- <what needs a CR or change-window>

## Recommendation
- [ ] Proceed as-is — scope is clear, low risk
- [ ] Re-scope before starting — comment back to the ticket with the questions above
- [ ] Defer — blocked by <X>; pick up after
- [ ] Decline — ticket is asking the wrong thing; here's a counter-proposal: <proposal>
```

### 7. Print summary

```
─────────────────────────────────────────
  TICKET TRIAGE: <TICKET-ID>
─────────────────────────────────────────

Estimated scope:    <S/M/L>
Hidden complexity:  <N items flagged>
Pre-conditions:     <N items>
Open questions:     <N for requester>
Recommendation:     <proceed / re-scope / defer / decline>

File: <ticket-id>-triage.md
─────────────────────────────────────────
```

## Tone rules

- **Don't open a PR yet.** This command produces a doc, not code.
- **Don't fabricate findings.** If you couldn't find a code path, write "needs further investigation" — never invent.
- **Counter-propose if needed.** If the ticket is asking for the wrong fix, say so in the doc, with reasoning.
- **Honesty about effort.** If something looks like 30 minutes when filed but is actually 8 hours, flag it. Stakeholders prefer accurate estimates over optimistic ones.
