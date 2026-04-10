You are doing a thorough code review of a GitHub PR and posting inline comments with code suggestions directly on GitHub.

PR reference: $ARGUMENTS

## Steps

### 1. Identify the PR
- If `$ARGUMENTS` is a number, use it directly as the PR number.
- If it's a branch name or partial title, run `gh pr list --search "$ARGUMENTS"` to find the PR number.
- Run `gh pr view <number> --json number,title,headRefName,headRefOid,baseRefName` to get PR metadata.
  - Save the `headRefOid` (latest commit SHA) — you'll need it for every comment.
  - Save the `number` (PR number).

### 2. Get the diff
Run `gh pr diff <number>` and read it in full. Pay attention to:
- File paths and line numbers (new file lines use `+`, counts start at 1 in the new file)
- Context lines that help you understand what the change does

### 3. Review the diff
Analyze every changed file for the following issues (not all will apply):

**Correctness**
- Logic bugs, off-by-one errors, missing edge cases
- Incorrect return values or missing early returns
- Null/None dereferences without guards

**Type safety & API contracts**
- Missing `Optional` when a parameter defaults to `None`
- Incorrect use of enum `.name` vs `.value`
- Wrong data types being passed or returned

**Security**
- Unvalidated input reaching SQL/shell/HTML
- Secrets or credentials in code

**Template / markup**
- Missing conditional guards around optional fields (e.g. rendering a `tel:` link without `{{#if phone}}`)
- Inconsistent quote styles in attribute values
- Inconsistent template variable syntax (e.g. `{{ var }}` vs `{{var}}`)
- Plural/singular copy inconsistencies between subject line and body

**Tests**
- Missing test for the happy path or a key edge case
- Tests that won't actually catch regressions (mocking too deep)

**Style & conventions**
- Naming inconsistencies with the rest of the file
- Dead code or unused imports introduced

### 4. Post inline comments
For **each real issue** found (skip nitpicks that don't affect correctness or maintainability):

```bash
gh api repos/{owner}/{repo}/pulls/comments \
  --method POST \
  --field commit_id="<headRefOid>" \
  --field path="<file_path>" \
  --field line=<line_number_in_new_file> \
  --field side="RIGHT" \
  --field body="<comment with code suggestion block if applicable>"
```

**Rules for comment body:**
- Be concise and specific — explain *why* it's an issue, not just that it is one.
- Always include a ` ```suggestion ` block when the fix is a 1–3 line change. The suggestion must be the exact replacement for the commented line(s) — GitHub applies it as a patch.
- For multi-line suggestions, use `--field start_line=<first_line>` and `--field line=<last_line>`.
- Do NOT post comments on lines that weren't changed in this PR.

### 5. Report
After posting all comments, print a summary table:

| File | Line | Issue |
|------|------|-------|
| ... | ... | ... |

Also print the PR URL so it's easy to open.
