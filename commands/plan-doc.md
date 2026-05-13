Generate a structured design / implementation plan document for a complex, multi-phase task. Output is markdown ready to publish to Confluence, Notion, or any wiki.

Topic or ticket: $ARGUMENTS

## When to use

Use this for tasks that:
- Span multiple phases or sprints
- Touch more than one system
- Need stakeholder buy-in before execution
- Have significant rollback/risk considerations
- Need to be repeatable for future similar work

Don't use this for simple bug fixes or single-PR features.

## Steps

### 1. Gather context

If `$ARGUMENTS` is a Jira ticket: fetch the ticket (description, comments, linked tickets) via the Atlassian MCP or `gh`-equivalent.

If it's a topic / Slack thread / Confluence link: ask the user for the source material before proceeding.

If it's a free-form description: ask the user to clarify scope before generating.

### 2. Investigate the codebase

For any tables, services, or systems mentioned in the topic:
- Locate the source-of-truth files (models, configs, jobs)
- Identify cross-system dependencies (events, downstream consumers, sync jobs)
- Note what's already built vs. what needs new code

Don't fabricate. If you can't find something in the repo, mark it as "needs verification" in the doc.

### 3. Identify hidden complexity

Specifically look for:
- **Pre-conditions** that must be true before execution (PID alignment, idle state, dependent merges)
- **Side effects** the main code path doesn't handle (downstream syncs, audit trails, cache invalidations)
- **Reversibility** — what's hard or impossible to undo
- **Stakeholders** beyond engineering (Ops, Finance, Customer Success, Security, DBA)

### 4. Generate the document

Use this exact structure:

```markdown
# <Title> — Plan

**Source ticket:** <link if applicable>
**Companion docs:** <related links>

---

## TL;DR

<2–3 paragraphs explaining what's changing and why. Include the
"good news / bad news" framing if there's a pre-built mechanism that
helps, or constraints that complicate it.>

The work required is:
1. ...
2. ...
3. ...

---

# Part 1 — <Domain Questions / Technical Doubts>

Answer the specific questions stakeholders have raised, in plain
language. One H2 per question.

## Q1. <First question>
**Short answer**: <one paragraph>
**What gets touched, by table/component**: <table>
**Edge cases**: <bullets>

## Q2. ...

---

# Part 2 — Subtask Breakdown

Discrete subtasks that can be assigned and tracked. Group by phase.

## Phase 0 — Pre-flight Validation
### Subtask 0.1 — <name>
- <step>
- **Output**: <tangible result>

## Phase 1 — <Cutover/Migration/Deploy>
### Subtask 1.1 — ...

## Phase 2 — ...

## Phase 3 — Validation & Stabilization
### Subtask 3.1 — ...

---

# Part 3 — Risk Register

| ID | Risk | Impact | Prob | Score | Severity | Mitigation |
| --- | --- | --- | --- | --- | --- | --- |
| R-01 | ... | 1–5 | 1–5 | I×P | High/Med/Low | ... |

Score: 12+ = High, 6–11 = Medium, 1–5 = Low.

**Summary**: N High, N Medium, N Low. Highlight the dominant risk family.

---

# Part 4 — Rollback Strategy

| Scenario | Rollback approach |
| --- | --- |
| ... | ... |

**Stop conditions** (when to abort and rollback rather than push forward):
- ...

---

# Part 5 — Communication Plan

| When | Audience | Channel | Message |
| --- | --- | --- | --- |
| T-3d | ... | ... | ... |

---

# Part 6 — Repeatability

How this becomes a playbook for similar future work.

---

# FAQ / Risk Mitigation

Add real questions from review here. Don't fabricate them; populate as
stakeholders raise them.

---

# Open Decisions

| # | Decision | Owner role | Deadline |
| --- | --- | --- | --- |

---

# Appendix — Reference SQL / Commands

Verification queries that support pre-flight and post-validation
steps.
```

### 5. Save the doc

Save to `<topic-slug>-plan.md` in the current working directory. Use kebab-case.

### 6. Print summary

```
─────────────────────────────────────────
  PLAN DOC GENERATED
─────────────────────────────────────────

File:        <path>
Length:      <N lines, N words>
Subtasks:    <N>
Risks:       <N total — N High, N Medium, N Low>
Open decisions: <N>

NEXT STEPS
  1. Review and adjust scope/owners
  2. Publish to Confluence or share link
  3. Tag stakeholders for input on Open Decisions
─────────────────────────────────────────
```

## Tone rules

- No names. Use roles ("sponsor", "engineering", "DBA", "customer success").
- No defensive language ("we managed to...", "as much as we could..."). State facts.
- Tables for structured data, prose for context.
- If you fabricate a number or claim you can't verify, flag it explicitly with `<!-- VERIFY -->`.
- Audience is mixed (PM, leads, engineers). Avoid deep jargon in TL;DR and Q-section; reserve it for Subtask Breakdown and Appendix.
