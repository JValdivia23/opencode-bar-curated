# SAFE_PATCH_PLAN.md

- Timestamp (UTC): 2026-02-12 19:16:00Z
- Based on findings: `SECURITY_REVIEW.md`
- Scope: hardening design + implementation status reconciliation

## Objective

Produce a safer local variant of `opgginc/opencode-bar` that minimizes sensitive access by default while preserving core quota visibility.

## Security Design Principles

1. Least privilege by default.
2. Explicit opt-in for browser cookie/keychain paths.
3. Deterministic, auditable behavior with clear source labeling.
4. No new outbound endpoints introduced by hardening.
5. No secret/token/cookie value logging.

## Confirmed Risk Drivers

1. Provider fetch is over-broad in app flow (`fetchAll` across all providers, then filter).
2. Copilot browser cookie extraction is default-on when provider runs.
3. CLI default command fetches all providers, including sensitive cookie path.
4. Sensitive auth sources are mixed, but user intent and consent are not explicit enough.

## Proposed Patch Set

### P1 - Fetch Only Enabled Providers (High priority)

**Problem**
- App path computes enabled providers but still invokes all-provider fetch.

**Patch**
- Add targeted fetch API in `ProviderManager`:
  - `fetchSelected(_ identifiers: Set<ProviderIdentifier>) -> FetchAllResult`
- Update `StatusBarController.fetchMultiProviderData()` to call selected-fetch only.

**Files**
- `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Services/ProviderManager.swift`
- `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/App/StatusBarController.swift`

**Security effect**
- Prevents unnecessary execution of providers that may access browser/keychain/process surfaces.

**Compatibility**
- No change to provider logic; only execution scope.

---

### P2 - Copilot Sensitive Mode Gate (High priority)

**Problem**
- Browser cookie + browser safe-storage keychain access can run without explicit user opt-in.

**Patch**
- Introduce explicit config gate:
  - key: `sensitiveAccess.copilotBrowserCookiesEnabled` (default `false`)
- In `CopilotProvider` and `CopilotCLIProvider`:
  - If gate is `false`, skip `BrowserCookieService` path entirely.
  - Use token-based path only (`TokenManager` + GitHub API token flows).
  - Return clear non-sensitive status when cookie-only features (history/card scrape) are unavailable.

**Files**
- `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Providers/CopilotProvider.swift`
- `upstream-opencode-bar/CopilotMonitor/CLI/Providers/CopilotCLIProvider.swift`
- `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Services/TokenManager.swift` (config helper)
- `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/App/StatusBarController.swift` (menu label/help text)

**Security effect**
- Browser secure-folder/keychain access becomes explicit opt-in instead of implicit default.

**Compatibility**
- Maintains baseline Copilot quota visibility via token sources.
- Advanced billing history remains optional.

---

### P3 - Safe CLI Default (Medium priority)

**Problem**
- `opencodebar status` currently executes all providers.

**Patch**
- Add CLI options for explicit scope:
  - `--provider <id>` (repeatable)
  - `--no-sensitive` (default behavior)
  - `--allow-sensitive` (explicitly enables sensitive providers/features)
- Keep default behavior as least-privilege (`--no-sensitive`).
- Wire to `CLIProviderManager.fetchSelected(...)` and sensitive gate checks.

**Files**
- `upstream-opencode-bar/CopilotMonitor/CLI/main.swift`
- `upstream-opencode-bar/CopilotMonitor/CLI/CLIProviderManager.swift`
- `upstream-opencode-bar/CopilotMonitor/CLI/Providers/CopilotCLIProvider.swift`

**Security effect**
- CLI automation no longer triggers browser-cookie access unless explicitly requested.

---

### P4 - Sensitive Access Audit Logging (Medium priority)

**Problem**
- Sensitive-path behavior is not consistently summarized for user auditability.

**Patch**
- Add structured logs for sensitive decisions only:
  - gate state,
  - path class used (token/cookie/keychain),
  - high-level source label.
- Enforce strict redaction:
  - never log token/cookie content,
  - never log raw file contents.

**Files**
- `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Services/BrowserCookieService.swift`
- `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Services/TokenManager.swift`
- `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Providers/CopilotProvider.swift`
- `upstream-opencode-bar/CopilotMonitor/CLI/Providers/CopilotCLIProvider.swift`

**Security effect**
- Improves traceability without increasing data exposure.

---

### P5 - Update/Telemetry Transparency Defaults (Medium priority)

**Problem**
- Auto-update network behavior is enabled by default; telemetry is not explicitly surfaced.

**Patch**
- Add explicit user-facing security settings section:
  - auto-update checks/downloads state,
  - sensitive access gate states.
- Keep telemetry integrations absent; document this in security notes.

**Files**
- `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/App/AppDelegate.swift`
- `upstream-opencode-bar/README.md` (or safe-build docs)

**Security effect**
- Improves consent/transparency posture.

## Non-Goals

1. No provider API protocol redesign.
2. No new remote services or analytics SDKs.
3. No removal of existing token-based provider support.
4. No dynamic execution in this design phase.

## Implementation Order

1. P1 (execution scope hardening)
2. P2 (sensitive-mode gating)
3. P3 (CLI safe defaults)
4. P4 (audit logging)
5. P5 (transparency settings/docs)

## Commit Save Point Plan

Create one auditable commit per boundary below (do not squash across boundaries):

1. Phase 3 docs finalized (`SECURITY_REVIEW.md`, `SAFE_PATCH_PLAN.md`, `PLAN.md` updates).
2. P1 complete (selected-provider fetch scope only).
3. P2 complete (Copilot browser-cookie gate default-off).
4. P3 complete (CLI safe defaults and sensitive flags).
5. P4 complete (redacted sensitive-path logging).
6. P5 complete (settings/transparency docs and UI text).
7. Post-implementation static verification report updates.
8. Optional Phase 4 dynamic findings (separate commit if executed).

## Verification Plan (Static-first)

For each patch, record exact evidence in follow-up report updates.

1. Code-path proof that disabled providers are not invoked.
2. Code-path proof that cookie/keychain path is unreachable when gate is `false`.
3. CLI argument behavior table (default vs `--allow-sensitive`).
4. Log review proof that secrets are never emitted.
5. Endpoint diff: no new outbound domains.

## Proposed Artifacts Update

After implementation, update:

1. `SECURITY_REVIEW.md` (mitigation mapping per finding)
2. `DYNAMIC_FINDINGS.md` (only if gated dynamic phase is approved/executed)
3. `PLAN.md` checklist progression

## Decision

- Proceed with Phase 5 implementation using this patch set.
- Dynamic testing gate was satisfied and Phase 4 safe-mode validation was executed (see `DYNAMIC_FINDINGS.md`).

## Implementation Status (Static)

- P1: implemented (selected provider fetch in app flow).
- P2: implemented (Copilot browser-cookie gate with default-off behavior).
- P3: implemented (CLI provider scoping and explicit sensitive-mode flags).
- P4: implemented.
  - Implemented: redacted, structured decision logging and source labels in token-path parsing (`quota source`) and sensitive gate behavior in Copilot paths.
  - Implemented: browser-cookie service debug logging now redacts cookie values and cookie DB path details.
  - Implemented: provider-layer logs explicitly report token-only vs sensitive-path selection.
- P5: implemented.
  - Implemented: app `Security` submenu surfaces auto-update checks/downloads state and Copilot sensitive-access gate state.
  - Implemented: user-facing docs updated to describe safe defaults and explicit opt-in behavior for browser-cookie fallback.

## Reconciliation Notes

1. Previous `P4/P5 pending` labels were stale after subsequent hardening work.
2. Dynamic evidence for safe-mode Copilot quota success and default-safe permission behavior is recorded in `DYNAMIC_FINDINGS.md`.
3. This file now reflects current status for phase-readiness decisions.
