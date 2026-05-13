Run a pre-merge / pre-deploy checklist. Surfaces all the things that block a clean cutover before you commit to it. Read-only — never makes changes.

Target: $ARGUMENTS  (PR number, PR URL, or a deploy target like a service name)

## When to use

Right before you:
- Merge a PR (especially infra, security, or prod-touching)
- Trigger a deploy
- Run a CR change-window
- Hand off an on-call task

Don't use this for routine merges of small bug fixes — it's overkill.

## Steps

### 1. Detect mode

If `$ARGUMENTS` is a PR number/URL → **PR mode**.

If it's a service name or deploy target → **Deploy mode**.

If ambiguous, ask the user.

---

## PR mode

### 1.1 Pull PR metadata

```bash
gh pr view <number> --json number,title,state,headRefOid,headRefName,baseRefName,author,mergeable,mergeStateStatus,reviewDecision,labels,milestone,statusCheckRollup,url,additions,deletions,changedFiles
```

### 1.2 Run each check

| Check | Pass criteria |
| --- | --- |
| State | `OPEN` and not `isDraft` |
| Mergeable | `MERGEABLE` (not `CONFLICTING` or `UNKNOWN`) |
| Reviews | `reviewDecision == APPROVED` |
| Required reviewers | All required CODEOWNERS reviewed (if applicable) |
| CI | All required checks `pass`; nothing `pending` longer than expected |
| Branch protection | `mergeStateStatus != BLOCKED`, or note why |
| Open inline comments | Count of `comments?position!=null`. Zero is ideal; if non-zero, list them. |
| Conflicts with main | `git fetch && git log origin/<base>..<head>` — has the branch fallen behind? |
| PR size | Flag if >500 lines added (often hides risk) |
| Linked issue | Has the PR body got a `Closes #X` or ticket link? |
| CHANGELOG / docs | If the repo has a CHANGELOG.md, was it updated? Heuristic only. |

### 1.3 Investigate stuck checks

For any check `pending` or `expected — waiting`:
- Is it a workflow that requires a workflow file in this repo? (Check `.github/workflows/`.)
- Is it a required check from org policy?
- Is the runner queue backed up?

Tell the user the most likely cause and suggested action (re-trigger via empty commit, ask owning team, etc.).

### 1.4 Print the report

```
─────────────────────────────────────────
  PRE-FLIGHT REPORT: PR #<N>
─────────────────────────────────────────

PR:                  <title>
State:               OPEN ✅ | DRAFT ❌
Mergeable:           MERGEABLE ✅ | CONFLICTING ❌
Reviews:             APPROVED ✅ (by N reviewers)
CI:                  18/18 pass ✅ | 1 fail ❌ | 1 expected-waiting ⏳
Open comments:       0 ✅ | 3 ⚠️ (list below)
Branch up to date:   ✅ | behind by N commits ⚠️
Size:                +85 / -12 ✅ | +850 / -300 ⚠️ (large)
Linked ticket:       FIRE-3857 ✅ | none ⚠️

Verdict: READY ✅ | INVESTIGATE ⚠️ | BLOCKED ❌

Action items (only if INVESTIGATE / BLOCKED):
- ...
─────────────────────────────────────────
```

---

## Deploy mode

### 2.1 Identify the deploy target

Ask or detect:
- What service / application?
- What environment (prod, stag, dev)?
- What's the deploy mechanism (ArgoCD, CircleCI, manual, AWS console)?
- Is there a CR / Change Request for this?

### 2.2 Run each check

| Check | Pass criteria |
| --- | --- |
| Backing PR merged | The change is on the deploy branch (`main`, `master`, etc.) |
| CI / build status | The image / artifact built successfully |
| Change Request approved | If required, CR is in `Approved` state, not `Pending Approval` |
| Pre-conditions documented | If there's a plan doc, list the pre-conditions and ask user to confirm each |
| Rollback plan known | User can describe the rollback in 1–2 sentences |
| Stakeholders notified | Have you told the channels listed in the comm plan? |
| Deploy window appropriate | Not the last hour of the day, not Friday afternoon, not during peak traffic |
| Backup / snapshot taken | If the change is destructive (DB migration, data move): is there a backup? |
| Monitoring ready | Do you know which dashboard / log query you'll watch? |
| On-call coverage | Who's the second pair of eyes during cutover? |

### 2.3 Print the report

```
─────────────────────────────────────────
  PRE-FLIGHT REPORT: <service> deploy
─────────────────────────────────────────

Service:        <name>
Environment:    <env>
Mechanism:      <ArgoCD / CircleCI / manual>
CR:             <CR-XXXX> — Approved ✅ | Pending ⚠️

Backing PR:     #N merged ✅ | not yet ❌
CI / build:     pass ✅ | fail ❌
Pre-conditions: N/N met ✅ | N/N met ⚠️
Rollback plan:  documented ✅ | unknown ⚠️
Stakeholders:   notified ✅ | not yet ⚠️
Deploy window:  appropriate ✅ | risky ⚠️
Backup taken:   yes ✅ | no ⚠️ | n/a
Monitoring:     dashboard <link> ✅ | unknown ⚠️
On-call:        <name/role> ✅ | unknown ⚠️

Verdict: GO ✅ | HOLD ⚠️ | NO-GO ❌

Outstanding items:
- ...
─────────────────────────────────────────
```

---

## Safety rules

- **Read-only command.** Never modifies any state, never pushes commits, never triggers deploys.
- If a check requires data that's not accessible (e.g., no AWS access for a baseline), mark it `unknown` rather than guess.
- The verdict (READY/GO) is advisory. Final call is the user's.
