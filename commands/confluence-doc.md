Publish a local markdown file to Confluence as a page (or update one). Handles tables, code blocks, links, headings, and lists. Outputs the live URL.

Source: $ARGUMENTS  (path to a .md file, or a topic if you want to compose first)

## Prerequisites

The Atlassian MCP must be configured. The user's `~/.dev-setup-config` should contain:

```bash
CONFLUENCE_HOST="yourcompany.atlassian.net"
CONFLUENCE_SPACE_KEY="ENG"
CONFLUENCE_PARENT_PAGE_ID=""   # optional: a default parent page
```

If any of these is missing, prompt the user before proceeding.

## Steps

### 1. Resolve the source

If `$ARGUMENTS` is an existing file path → use that.

If it's a topic ("draft a doc about X") → ask the user to write or generate the markdown first, or invoke `/plan-doc` to generate it.

### 2. Inspect the markdown

- Read the file
- Detect the title (first H1 line)
- Strip the title from the body (Confluence sets it via the `title` field, you don't want it duplicated)

### 3. Resolve the parent page

Priority order:
1. If user passes `--parent <page-id>` in `$ARGUMENTS`, use it
2. If the markdown has a `Companion docs` or `Source ticket` section linking to a Confluence page, propose using that as parent
3. Else ask the user: "Publish under space `<key>` root, or specify a parent page ID?"

### 4. Decide create vs. update

- If the user passes `--update <page-id>`, update that page
- If they pass `--page-id <id>`, same thing
- Otherwise create new

### 5. Choose content format

Default: markdown (the MCP renders it). If the doc has unusual content (Confluence panels, status lozenges, expand/collapse sections), the user should specify `--html` and provide HTML, or this command should map common patterns to Confluence storage format.

For now, ship as markdown — the MCP handles tables, code blocks, headings, lists, and inline formatting cleanly.

### 6. Publish

For create:
```
mcp__atlassian__createConfluencePage(
  cloudId: <CONFLUENCE_HOST>,
  spaceId: <looked-up from CONFLUENCE_SPACE_KEY>,
  parentId: <parent>,
  subtype: "live",   # live page = collaborative editing enabled
  title: <extracted title>,
  contentFormat: "markdown",
  body: <body without H1>
)
```

For update: pass `pageId` and a `versionMessage` describing the change.

### 7. Output

```
─────────────────────────────────────────
  CONFLUENCE DOC PUBLISHED
─────────────────────────────────────────

Title:       <title>
Space:       <space key>
Parent:      <parent page name or "(root)">
URL:         https://<host>/wiki/spaces/<key>/pages/<id>/<slug>
Version:     <number>
Mode:        created | updated

NEXT STEPS
  1. Share the link with stakeholders
  2. If this is a long-lived doc, add it to a navigation page
  3. If it has open questions, tag the right roles
─────────────────────────────────────────
```

### 8. Optional: link back to Jira

If the source markdown mentions a Jira ticket and the user has the Atlassian MCP, offer to add a comment to that ticket pointing to the new Confluence page.

## Tone rules / safeguards

- **Never publish without confirming title and parent** with the user.
- **For updates**, show the user what version they're updating from and what the change message will say.
- **Don't strip user content** silently. If you reformat anything, list the changes ("removed leading H1", "converted indented code to fenced code blocks").
- If a publish fails (token expired, permission denied, parent not found), suggest the fix and don't retry blindly.
