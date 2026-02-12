# AGENTS.md

This repository root is an **audit workspace**, not the app source itself.

Primary goal: uninstall, review, audit, and produce a hardened/safe version of `opgginc/opencode-bar`.

The audited upstream source is located at:
- `upstream-opencode-bar/`

Original repo is https://github.com/opgginc/opencode-bar
We found suspicious permission request, so we want to create a safe version of it.
## Mission

All agent work in this root must prioritize:
1. Security review and traceability
2. Minimal-risk, static-analysis-first workflow
3. Clear evidence artifacts (`*_REPORT.md`, `*_FINDINGS.md`)
4. Hardened patch design with explicit rationale

Do **not** treat this workspace as a normal feature-dev repo.

## Operating Mode

- Default mode: **static analysis only**
- Dynamic execution is optional and only allowed after static findings indicate low risk
- Never request/accept browser secure-storage access during analysis
- Never use personal browser profiles/cookies as test fixtures

## Workspace Structure

- `PLAN.md` - master plan and execution checklist
- `PHASE0_ENVIRONMENT.md` - environment baseline
- `PHASE1_UNINSTALL_REPORT.md` - uninstall verification
- `AUDIT_BASELINE.md` - pinned upstream SHA + trust snapshot
- `SECURITY_REVIEW.md` - static findings and mitigation verification
- `DYNAMIC_FINDINGS.md` - dynamic verification evidence (when executed)
- `SAFE_PATCH_PLAN.md` - hardening patch plan and implementation status
- `upstream-opencode-bar/` - cloned upstream project under review

## Current Audit Status (2026-02-12 UTC)

- Phase 0-4: completed.
- Phase 5: completed for planned hardening set (P1-P5).
- Phase 6: completed - CLI installed and functional.
- Upstream hardening implementation checkpoint: `upstream-opencode-bar` commit `31dc685`.
- CLI binary installed: `/usr/local/bin/opencodebar`
- All quota tests passing: Copilot, OpenAI, Google
- Status: **Audit complete - ready for use**

## Source of Truth

- For audit process and constraints: this file + `PLAN.md`
- For upstream coding conventions only when editing upstream files: `upstream-opencode-bar/AGENTS.md`

If the two conflict, prioritize this root `AGENTS.md` for audit behavior.

## Allowed Command Categories

### Audit / Discovery
```bash
# repo identity
git -C upstream-opencode-bar remote -v
git -C upstream-opencode-bar rev-parse HEAD
git -C upstream-opencode-bar log --oneline -n 20

# search for sensitive behavior
rg -n "quota|auth|cookie|keychain|browser|Library/Application Support|exec\(|Process\(" upstream-opencode-bar

# locate command paths
rg -n "quota" upstream-opencode-bar/CopilotMonitor
```

### Trust / Metadata
```bash
gh repo view opgginc/opencode-bar --json nameWithOwner,defaultBranchRef,stargazerCount,forkCount,issues,latestRelease
gh issue list --repo opgginc/opencode-bar --state all --limit 50
```

### Optional Build/Test (Gated)
Only run after static review permits dynamic verification.
```bash
cd upstream-opencode-bar
make lint
cd CopilotMonitor
xcodebuild -project CopilotMonitor.xcodeproj -scheme CopilotMonitor -destination 'platform=macOS' test
```

Single test examples (only if gated):
```bash
cd upstream-opencode-bar/CopilotMonitor
xcodebuild -project CopilotMonitor.xcodeproj -scheme CopilotMonitor -destination 'platform=macOS' \
  -only-testing:CopilotMonitorTests/ClaudeProviderTests test

xcodebuild -project CopilotMonitor.xcodeproj -scheme CopilotMonitor -destination 'platform=macOS' \
  -only-testing:CopilotMonitorTests/ClaudeProviderTests/testProviderIdentifier test
```

## Required Audit Outputs

For each completed phase, produce or update a markdown artifact with:
- Date/time (UTC)
- Exact commands used
- Evidence summary
- Risks found
- Decision and next action

Minimum expected outputs:
- `SECURITY_REVIEW.md` (static findings)
- `DYNAMIC_FINDINGS.md` (only if dynamic phase is executed)
- `SAFE_PATCH_PLAN.md` (hardening design)

## Security Review Checklist

When reviewing code, explicitly map:
1. Quota command entry points
2. Auth/token file discovery logic
3. Browser cookie/profile access logic
4. Keychain/credential APIs
5. Shell/process execution surfaces
6. Outbound network endpoints and payload classes
7. Telemetry defaults and opt-out behavior

## Coding and Change Rules (Audit Context)

- Keep changes minimal and auditable
- Prefer small, focused patches over broad refactors
- Add comments only when behavior is non-obvious
- Keep all new docs/comments/user-facing text in English
- Do not introduce new network calls in hardening patches unless justified
- Do not log secrets, tokens, raw cookies, or private file contents

## Risk Handling Rules

- If suspicious behavior is confirmed, stop execution and document immediately
- If behavior is ambiguous, prefer conservative interpretation and request clarification
- If sensitive access is unnecessary, propose default-off and explicit opt-in

## Git Rules for This Workspace

- Do not rewrite history (`reset --hard`, force push) unless explicitly requested
- Do not amend commits unless explicitly requested
- Do not commit unrelated files
- Commit only when user asks for a commit

## Quick Start for Agents

1. Read `PLAN.md`
2. Read latest phase report files
3. Confirm pinned SHA in `AUDIT_BASELINE.md`
4. Continue next unchecked checklist item
5. Record evidence and decisions in a new/updated report

## Definition of Done (Audit Track)

Done means:
- Suspicious permission path is fully explained with code references
- Necessity of browser secure-folder access is proven or disproven
- Hardened approach is documented and implemented (if requested)
- Verification evidence is reproducible from pinned commit and reports
