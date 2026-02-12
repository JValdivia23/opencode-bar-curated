# PLAN.md

## Goal
Uninstall the current `opencode-bar` install, audit the upstream codebase, and produce a hardened "safe" local version with minimized permissions and transparent behavior.

## Success Criteria
- Existing install is removed and no background/autostart remnants remain.
- We identify exactly why quota checks request browser secure-folder access.
- We document all sensitive file/system access and outbound network calls.
- We produce a hardened fork/build that:
  - avoids browser secure-folder access (or gates it behind explicit opt-in),
  - clearly logs when/why sensitive access occurs,
  - disables non-essential telemetry by default,
  - passes functional checks for core commands (including quota checks).

---

## Phase 0 - Safety Baseline (No Trust Assumptions)
1. **Pause use of current install**
   - Do not grant additional permissions.
   - If permissions were already granted, rotate high-value sessions/tokens later in this plan.

2. **Capture environment snapshot (for traceability)**
   - OS version, shell, package manager(s), path to executable.
   - Current config/cache/data directories used by the tool.

3. **Isolation strategy for review - Pure Static Analysis**
   - **Approach:** Never run the cloned code on the main system
   - All review work stays in this isolated directory: `/Users/java1127/Library/CloudStorage/OneDrive-UCB-O365/Projects/opencode-bar`
   - Read and analyze source code only to understand behavior
   - If suspicious behavior is found, stop before any execution
   - **Optional (if we proceed to testing):** Use network monitoring (Little Snitch) and filesystem monitoring (Console/fs_usage) to observe what the code *tries* to do without allowing access to sensitive data

**Deliverable:** short environment note with tool binary path and install method.

---

## Phase 1 - Uninstall Current Version + Residual Cleanup
> We will choose uninstall steps based on how it was installed (npm/pnpm/bun/brew/manual).

1. **Identify install source**
   - Check executable location and package manager ownership.
   - Record candidate paths:
     - global binaries (`which`, symlink targets),
     - app support/config/cache dirs in `~/Library/...`,
     - launch agents/daemons if any.

2. **Uninstall by source**
   - If package-manager install: use that manager's uninstall command.
   - If manual binary/symlink: remove binary + symlink safely.
   - If app bundle: remove app and related support files.

3. **Remove residual data**
   - Remove tool-specific config/cache/state folders.
   - Remove launch agents/startup entries if present.
   - Keep a backup copy only if needed for diffing behavior.

4. **Post-uninstall verification**
   - `which`/`command -v` should not resolve executable.
   - No running process.
   - No active launch entries related to the tool.

**Deliverable:** uninstall checklist with before/after evidence.

---

## Phase 2 - Clone + Trust Verification
1. **Clone upstream**
   - Clone official repo into a clean workspace.
   - Record remote URL and default branch.

2. **Verify repository trust signals**
   - Confirm maintainer/org, stars/activity consistency, release tags.
   - Inspect open issues for security concerns around permissions/access.
   - Verify lockfiles and dependency manager are present and sane.

3. **Pin baseline commit**
   - Record exact commit SHA to audit.
   - Create internal branch for security review notes.

**Deliverable:** `AUDIT_BASELINE.md` with repo URL, audited SHA, date.

---

## Phase 3 - Static Security Review (Focus: Quota Flow)
1. **Map quota command execution path**
   - Locate CLI command handler for "quota".
   - Trace downstream modules/services invoked.

2. **Sensitive access inventory**
   - Search for:
     - browser profile/secure storage paths,
     - keychain/credential APIs,
     - filesystem reads under browser data dirs,
     - shell execution (`exec/spawn`),
     - env var harvesting.
   - Document purpose and call sites.

3. **Network/telemetry inventory**
   - Enumerate all outbound endpoints and payload types.
   - Separate required API calls from optional telemetry/analytics.

4. **Permission rationale analysis**
   - Determine if browser secure-folder access is:
     - required for auth/session reuse,
     - legacy implementation detail,
     - unnecessary/suspicious.
   - Propose safer alternatives (token file, explicit OAuth, API key env var).

5. **Dependency risk triage**
   - Review high-risk dependencies (auth, updater, telemetry, native bindings).
   - Check known vulnerabilities (`npm audit`/equivalent later during execution phase).

**Deliverable:** `SECURITY_REVIEW.md` with findings ranked by severity.

### Phase 3 Exit Criteria (Go/No-Go to Phase 4)

- `SECURITY_REVIEW.md` completed with ranked findings and code references.
- `SAFE_PATCH_PLAN.md` completed with least-privilege hardening design.
- Commit save-point plan documented before implementation/dynamic execution.
- If high-severity least-privilege gaps remain unmitigated, defer Phase 4.

---

## Phase 4 - Optional Dynamic Analysis (Conditional)
> ⚠️ **This phase is OPTIONAL and only if static analysis shows the code is trustworthy**

1. **Pre-conditions for dynamic testing**
   - Static analysis must show no obvious malicious behavior
   - Code must have clear, justified reasons for any sensitive access
   - User explicitly approves proceeding to execution

2. **If proceeding to test**
   - Use network monitoring (Little Snitch) to block/alert on connections
   - Use filesystem monitoring (Console, `fs_usage`) to see file access attempts
   - Run in isolated environment with no access to:
     - Browser profiles/secure storage
     - Keychain
     - Sensitive personal files
   - Observe what the code *tries* to do without allowing harmful actions

3. **Permission prompt reproduction**
   - Only if static analysis suggests it might be legitimate
   - Capture exact prompt text and timing
   - Verify against code path findings

**Deliverable:** `DYNAMIC_FINDINGS.md` (only if this phase is executed) OR note that phase was skipped due to findings in Phase 3.

---

## Phase 5 - Hardening the Codebase (Safe Version)
1. **Design hardening changes**
   - Remove/replace browser secure-folder dependency when possible.
   - Introduce explicit consent gates for sensitive access.
   - Add `--no-telemetry` default and config transparency.
   - Add clear startup warning if sensitive mode enabled.

2. **Implement minimal, auditable changes**
   - Prefer small diffs and feature flags.
   - Add structured logs for sensitive operations (path redacted).
   - Ensure secrets are never logged.

3. **Add tests**
   - Unit tests for quota flow without browser access.
   - Integration test to verify command works with safe auth mode.
   - Regression tests to ensure sensitive paths are not touched by default.

4. **Documentation**
   - Security model, permissions needed, and why.
   - "Safe mode" usage instructions.
   - Migration notes from upstream behavior.

**Deliverable:** hardened branch + test coverage for modified flows.

---

## Phase 6 - Verification, Packaging, and Maintenance
1. **Quality gates**
   - Lint, typecheck, unit/integration tests all green.
   - Dependency audit run and reviewed.
   - Manual smoke test for primary CLI commands.

2. **Package safe build**
   - Build reproducibly from pinned commit + patch set.
   - Generate checksums for produced artifacts.
   - Keep install instructions explicit and minimal.

3. **Ongoing update process**
   - Monthly upstream diff review.
   - Rebase hardening patch set on new releases.
   - Re-run security regression checklist.

**Deliverable:** `RELEASE_NOTES_SAFE.md` and reproducible build notes.

---

## Threat Model (Working)
- **Assets:** API tokens, browser sessions/cookies, local secrets, command history.
- **Risks:** unnecessary secure-folder access, silent telemetry, token leakage, malicious dependency behavior.
- **Assumption:** upstream is not trusted until code-path and runtime behavior are verified.

---

## Execution Checklist (Condensed)
- [x] Identify install method and uninstall completely.
- [x] Clone official repo and pin SHA.
- [x] Trace quota code path and sensitive APIs.
- [x] Review static analysis findings - decide if dynamic testing is safe.
- [x] Document hardening patch plan and commit save points.
- [x] (Optional) Capture runtime file/network behavior in sandbox.
- [x] Implement and test hardening changes.
- [x] Build and document safe release process.

## Commit Save Points (Audit Traceability)

- [x] Save Point 1: Phase 3 docs finalized (`SECURITY_REVIEW.md`, `SAFE_PATCH_PLAN.md`, `PLAN.md`).
- [x] Save Point 2: P1 complete (selected-provider fetch scope only).
- [x] Save Point 3: P2 complete (Copilot browser-cookie gate default-off).
- [x] Save Point 4: P3 complete (CLI safe defaults).
- [x] Save Point 5: P4 complete (redacted sensitive-path logging).
- [x] Save Point 6: P5 complete (transparency settings/docs).
- [x] Save Point 7: Phase 6 verification complete (`PHASE6_VERIFICATION.md`, `RELEASE_NOTES_SAFE.md`).
- [x] Save Point 8: Optional Phase 4 dynamic findings docs.

Checkpoint note:
- Save Points 2-6 were grouped into one upstream commit due overlapping file boundaries during hardening implementation (`31dc685`).
- Phase 6 completed with full verification, quota tests, and release documentation.

---

## Open Decisions
1. **Preferred auth approach for safe build**
   - API key via env/config (recommended),
   - explicit OAuth device flow,
   - optional browser session import (off by default).
2. **Telemetry default**
   - fully off by default (recommended),
   - opt-in at first run.
3. **Distribution**
   - local-only build,
   - private fork with signed releases.
