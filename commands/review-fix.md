Review all open comments on your own PR branch, push back on incorrect ones, and fix the valid ones.

PR branch or number: $ARGUMENTS

## Steps

### 1. Identify the PR
- If `$ARGUMENTS` is a number, use it directly.
- If it's a branch name, run `gh pr list --head "$ARGUMENTS"` to find the PR.
- Run `gh pr view <number> --json number,headRefName,headRefOid,baseRefName,url` to get metadata.
- Confirm the PR author is you (the current git user). If it's someone else's PR, stop and warn.

### 2. Fetch all unresolved review comments
```bash
gh api repos/{owner}/{repo}/pulls/<number>/comments \
  --jq '[.[] | select(.position != null) | {id, path, line: .original_line, body, diff_hunk, user: .user.login, url: .html_url}]'
```
Also fetch top-level PR review threads to catch any review-level comments:
```bash
gh api repos/{owner}/{repo}/pulls/<number>/reviews \
  --jq '[.[] | select(.state != "APPROVED") | {id, state, body, user: .user.login}]'
```

### 3. For each inline comment — decide: fix or push back

Read the file at the commented location using the Read tool. Then for each comment:

**A — The comment is VALID** (the reviewer is correct):
- Make the exact code change using Edit tool
- Record the fix for the commit message
- Reply to the comment thread:
  ```bash
  gh api repos/{owner}/{repo}/pulls/comments/<comment_id>/replies \
    --method POST \
    --field body="Fixed — <one sentence describing what changed>."
  ```

**B — The comment is NOT VALID** (the suggestion is incorrect, unnecessary, or based on a misunderstanding):
- Do NOT change the code
- Reply to the comment thread with a polite, technical explanation:
  ```bash
  gh api repos/{owner}/{repo}/pulls/comments/<comment_id>/replies \
    --method POST \
    --field body="<explanation of why the current code is correct>"
  ```
  Keep the tone collaborative, not defensive. Cite specifics (spec, existing pattern, reason).

**C — The comment is a question or needs clarification**:
- Reply with an explanation of the intent behind the code.

### 4. Commit and push all fixes
If any files were modified:
```bash
git add <changed files>
git commit -m "fix(<scope>): address PR review comments"
git push
```
Do NOT amend — create a new commit so the reviewer can see what changed.

### 5. Summary report
Print a table:

| File | Line | Reviewer | Decision | Action taken |
|------|------|----------|----------|--------------|
| `path/to/file.py` | 42 | reviewer | Fixed | Changed X to Y |
| `path/to/other.py` | 17 | reviewer | Pushed back | Explained why current approach is correct |

Then print the PR URL.
