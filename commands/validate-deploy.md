End-to-end smoke test for a deploy or production change. Capture a baseline before the change, re-test after, and produce a concrete diff report.

Target: $ARGUMENTS  (URL, hostname, service name, or "<host>:<port>")

## When to use

After:
- Cert rotations (TLS handshake change)
- Config swaps (annotation changes, env var bumps)
- Image promotions
- DNS / load balancer changes
- Any prod cutover where you want a recorded before/after

## Steps

### 1. Parse the target

Extract:
- Host or service name
- Port (default 443 for https, 80 for http)
- Optional path (default `/`)

If the user passes a URL, derive these. If they pass a service name without a host, ask for the host.

### 2. Decide what to capture

Based on the kind of target:

**TLS / certificate change:**
- SHA256 fingerprint
- Subject, Issuer
- NotBefore / NotAfter
- Serial number

**HTTP behavior:**
- Status code
- Response headers (Server, X-*, Cache-Control)
- Response time (rough)

**Downstream services** (if a list is provided in `$ARGUMENTS` or detected from the topic):
- HTTP status
- TLS handshake success/failure

### 3. Capture BASELINE

Run before the change. Save to `/tmp/<service>-baseline-<timestamp>.txt`.

Example for TLS:
```bash
echo | openssl s_client -showcerts -servername <host> -connect <host>:<port> 2>/dev/null \
  | openssl x509 -noout -fingerprint -sha256 -subject -issuer -dates -serial
```

Example for HTTP:
```bash
curl -sI -m 10 https://<host><path> | head -10
```

Print the captured baseline to the user. Confirm they want to proceed (the actual change happens outside this command — merge, deploy, etc.).

### 4. Wait, then capture POST-CHANGE

After the user confirms the change has been made, wait 30s and capture the same metrics again. Save to `/tmp/<service>-post-<timestamp>.txt`.

If still showing baseline state (e.g., fingerprint unchanged), wait another 60s and re-check. Stop after 5 minutes total — that's a clear signal the deploy didn't propagate.

### 5. Compare and report

Generate a side-by-side table:

| Field | Before | After | Changed? |
| --- | --- | --- | --- |
| SHA256 Fingerprint | `74:ED:...` | `C9:5B:...` | ✅ |
| Subject | `/CN=...` | `/CN=...` | (same — expected) |
| NotAfter | Oct 29 2026 | Nov 3 2026 | ✅ |
| ... | ... | ... | ... |

For HTTP: compare status codes and key headers.

Highlight unexpected diffs:
- Status code dropped from 200 to 5xx → red flag
- Subject changed unexpectedly (cert change to wrong domain) → red flag
- Fingerprint did NOT change when it should have → deploy didn't propagate

### 6. Smoke test downstream services (if applicable)

If the user provided a list of dependent services, hit each with `curl -sI -m 5` and report:

| Service | Status | TLS handshake |
| --- | --- | --- |
| service-a.example.com | HTTP 200 | ✅ |
| service-b.example.com | HTTP 401 | ✅ (auth required, normal) |
| service-c.example.com | timeout | ❌ |

4xx codes without payload are usually OK (just means the endpoint needs a real request). 5xx and timeouts are red flags.

### 7. Final verdict

```
─────────────────────────────────────────
  DEPLOY VALIDATION: <PASS | INVESTIGATE | FAIL>
─────────────────────────────────────────

Target:        <host>
Baseline at:   <timestamp>
Post-change:   <timestamp>

Changes detected:
- <field>: <before> → <after>

Downstream services: N/N healthy

Recommendation:
  PASS         → deploy is propagated and healthy
  INVESTIGATE  → fingerprint changed but downstream shows degradation
  FAIL         → expected change did not occur within 5 min, or 5xx detected
─────────────────────────────────────────
```

### 8. Save the report

Write the full report to `<service>-deploy-validation-<timestamp>.md` in the current directory. The user can paste this into Slack, ticket, or a release log.

## Safety rules

- Use `-m 5` or `-m 10` timeouts. Never let curl hang indefinitely.
- No POST/PUT/DELETE in smoke tests. GET / HEAD only.
- Don't include auth tokens in the captured headers.
- If a baseline was never captured, refuse to declare PASS — say "no baseline, manual verification needed".
