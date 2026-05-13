Pre-merge guard for a GitHub PR: check approvals, CI status, branch protection, open comments, then merge with the right strategy and report post-merge state.

PR: $ARGUMENTS

## Steps

### 1. Resolve the PR
- If `$ARGUMENTS` is a number, use it.
- If it's a branch name or partial title, run `gh pr list --search "$ARGUMENTS"` to find the number.
- Run `gh pr view <number> --json number,title,state,headRefOid,headRefName,baseRefName,author,mergeable,mergeStateStatus,reviewDecision,url` and save the data.

### 2. Confirm the PR is mergeable

Block with a clear message and exit if any of these are true:
- `state != "OPEN"`
- `mergeable != "MERGEABLE"` (could be CONFLICTING; tell the user to rebase)
- `reviewDecision != "APPROVED"` (could be REVIEW_REQUIRED, CHANGES_REQUESTED)

If `mergeStateStatus == "BLOCKED"`, dig deeper: there may be required checks waiting or admin protections.

### 3. Check CI

Run `gh pr checks <number>` and parse:
- All checks `pass`? → continue
- Any `fail`? → list them and ask the user to confirm before merge (sometimes failures are unrelated, e.g. flaky cypress)
- Any `pending` or `expected — waiting`? → tell the user the check is stuck; offer to push an empty commit to retrigger

Give the user a 1-line decision prompt: "CI status: 18 pass, 1 expected-waiting (DevPortal). Continue with merge anyway? (admin override / wait / abort)"

### 4. Check unresolved comments

Run `gh api repos/{owner}/{repo}/pulls/<number>/comments --paginate --jq '[.[] | select(.position != null)] | length'` to count unresolved inline comments.

If > 0, list them briefly and ask the user to confirm. Don't auto-merge over open threads.

### 5. Choose merge strategy

Default: `--squash`. Use `--merge` if:
- The repo's recent merges show all merge commits (check `git log origin/<base> --oneline | head -10`)
- The user passes `--merge-commit` as part of `$ARGUMENTS`

Use `--rebase` only if explicitly asked.

Confirm with the user before merging:
> "Merging PR #N with --squash. Title: <title>. Continue?"

### 6. Merge

Run `gh pr merge <number> --repo <repo> --squash` (or the chosen strategy).

Capture the merge commit SHA from the output.

### 7. Post-merge validation

Print:
```
─────────────────────────────────────────
  PR MERGED
─────────────────────────────────────────

PR:           #<number> <title>
Merged at:    <ISO timestamp>
Merge SHA:    <short>
Strategy:     squash | merge | rebase
Branch:       <head> → <base>
─────────────────────────────────────────
```

If the project has obvious post-merge sync (CI/CD, ArgoCD, image build), print a hint:
> "Watch the deploy: <expected pipeline URL or argo app name>"
> "Sync usually completes in 1–3 min."

### 8. Optional: post-deploy reminder

If the user said "validate after merge" or similar in `$ARGUMENTS`, also suggest running `/validate-deploy <service-url>` to capture pre/post baseline.

## Safety rules

- **Never merge** if `reviewDecision == "CHANGES_REQUESTED"` even with admin permissions, unless the user explicitly says "force merge".
- **Never use --no-verify** on the merge command itself.
- **Never auto-resolve** open review threads from the CLI; ask the author/reviewer to do it.
- **Don't bypass branch protection** unless the user is the repo admin AND explicitly asks.
- If you push an empty commit to retrigger CI, mention it in the PR (1-line comment) so the author knows.
