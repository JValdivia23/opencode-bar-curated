# SECURITY_REVIEW.md

- Timestamp (UTC): 2026-02-12 18:12:25Z
- Phase: 3 (Static Security Review)
- Audit mode: Static analysis only (no runtime execution)
- Audited project: `opgginc/opencode-bar`
- Pinned SHA: `94c95d984ed9b2dae1f1be62350ab69fd0093774`

## Commands Used (Static)

Note: this environment does not provide `rg` in shell. Static review used repository-safe file queries (`grep`, `glob`, `read`) only.

1. `read PLAN.md`, `read PHASE0_ENVIRONMENT.md`, `read PHASE1_UNINSTALL_REPORT.md`, `read AUDIT_BASELINE.md`
2. `grep "quota" upstream-opencode-bar`
3. `grep "auth.json|token|keychain|cookie|browser|Application Support" upstream-opencode-bar`
4. `grep "Process\(|exec\(|spawn|do shell script" upstream-opencode-bar`
5. `grep "https?://|URL\(|URLRequest|telemetry|analytics|posthog|sentry" upstream-opencode-bar`
6. `read` of traced code paths:
   - `upstream-opencode-bar/CopilotMonitor/CLI/main.swift`
   - `upstream-opencode-bar/CopilotMonitor/CLI/CLIProviderManager.swift`
   - `upstream-opencode-bar/CopilotMonitor/CLI/Providers/CopilotCLIProvider.swift`
   - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/App/StatusBarController.swift`
   - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Services/ProviderManager.swift`
   - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Services/TokenManager.swift`
   - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Services/BrowserCookieService.swift`
   - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Services/CopilotHistoryService.swift`
   - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Providers/*.swift`
   - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/App/AppDelegate.swift`
   - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Info.plist`

## Phase 3 Checklist Mapping

### 1) Quota command execution path

#### App flow (menu refresh)

1. `StatusBarController.fetchUsage()` triggers `fetchMultiProviderData()`.
   - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/App/StatusBarController.swift:351`
   - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/App/StatusBarController.swift:376`
2. `fetchMultiProviderData()` calls `ProviderManager.shared.fetchAll()`.
   - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/App/StatusBarController.swift:401`
3. `ProviderManager.fetchAll()` iterates *all registered providers* and executes `provider.fetch()` for each.
   - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Services/ProviderManager.swift:28`
   - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Services/ProviderManager.swift:89`
   - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Services/ProviderManager.swift:232`

#### CLI flow (`opencodebar status` / default)

1. CLI entrypoint defaults to `StatusCommand`.
   - `upstream-opencode-bar/CopilotMonitor/CLI/main.swift:238`
2. `StatusCommand.run()` calls `CLIProviderManager.fetchAll()`.
   - `upstream-opencode-bar/CopilotMonitor/CLI/main.swift:259`
3. `CLIProviderManager.fetchAll()` also executes all providers, including `CopilotCLIProvider`.
   - `upstream-opencode-bar/CopilotMonitor/CLI/CLIProviderManager.swift:39`
   - `upstream-opencode-bar/CopilotMonitor/CLI/CLIProviderManager.swift:64`

### 2) Sensitive access inventory

#### Browser profile / secure storage access

- Browser cookie DB scanning for Chrome/Brave/Arc/Edge in `~/Library/Application Support/.../Cookies`.
  - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Services/BrowserCookieService.swift:314`
  - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Services/BrowserCookieService.swift:320`
- Keychain access for browser safe-storage secrets (`Chrome Safe Storage`, etc.) via `SecItemCopyMatching`.
  - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Services/BrowserCookieService.swift:94`
  - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Services/BrowserCookieService.swift:103`
- Cookie extraction call sites:
  - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Providers/CopilotProvider.swift:45`
  - `upstream-opencode-bar/CopilotMonitor/CLI/Providers/CopilotCLIProvider.swift:25`
  - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Services/CopilotHistoryService.swift:26`

#### Auth/token file discovery

- Multi-path `auth.json` discovery:
  - `$XDG_DATA_HOME/opencode/auth.json`
  - `~/.local/share/opencode/auth.json`
  - `~/Library/Application Support/opencode/auth.json`
  - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Services/TokenManager.swift:562`
- Additional credential files:
  - `~/.codex/auth.json`
  - `~/.config/github-copilot/{hosts.json,apps.json}` and `~/Library/Application Support/github-copilot/{hosts.json,apps.json}`
  - `~/.gemini/oauth_creds.json`
  - `~/.config/opencode/antigravity-accounts.json`
  - Claude files `~/.config/claude-code/auth.json`, `~/.claude/.credentials.json`
  - Keychain services `Claude Code-credentials`, `Claude Code`

#### Shell/process execution surfaces

- Local process execution (`Process`) in providers:
  - Antigravity: `/bin/ps`, `/usr/sbin/lsof` inspection and localhost API call support.
    - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Providers/AntigravityProvider.swift:150`
    - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Providers/AntigravityProvider.swift:182`
  - OpenCode Zen: executes `opencode stats`, `which opencode`, login-shell `which`, and `pkill -f "opencode stats"`.
    - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Providers/OpenCodeZenProvider.swift:126`
    - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Providers/OpenCodeZenProvider.swift:160`
    - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Providers/OpenCodeZenProvider.swift:510`
    - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Providers/OpenCodeZenProvider.swift:476`
- Privileged AppleScript path for CLI install to `/usr/local/bin`.
  - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/App/StatusBarController.swift:1947`

### 3) Network / telemetry inventory

Observed outbound endpoint classes:

- Usage APIs (provider quota/billing):
  - Anthropic: `https://api.anthropic.com/api/oauth/usage`
  - OpenAI/Codex: `https://chatgpt.com/backend-api/wham/usage`
  - GitHub: `https://api.github.com/copilot_internal/user`, `https://api.github.com/user`
  - GitHub billing pages/api-style endpoints: `https://github.com/settings/billing`, `.../copilot_usage_card`, `.../copilot_usage_table`
  - Gemini: `https://cloudcode-pa.googleapis.com/v1internal:retrieveUserQuota`, `https://oauth2.googleapis.com/token`, `https://www.googleapis.com/oauth2/v1/userinfo?alt=json`
  - Kimi: `https://api.kimi.com/coding/v1/usages`
  - Z.AI: `https://api.z.ai/api/monitor/usage/quota/limit`, `/model-usage`, `/tool-usage`
  - OpenRouter: `https://openrouter.ai/api/v1/credits`, `/key`
  - Chutes: `https://api.chutes.ai/users/me`, `/users/me/quotas`, `/users/me/quota_usage/{id}`
  - Synthetic: `https://api.synthetic.new/v2/quotas`
  - OpenCode: `https://api.opencode.ai/v1/credits`
- Local-only endpoint:
  - Antigravity local service: `https://127.0.0.1:{port}/exa.language_server_pb.LanguageServerService/GetUserStatus`
- Update channel:
  - Sparkle appcast feed in `Info.plist`:
    - `https://github.com/opgginc/opencode-bar/releases/latest/download/appcast.xml`
    - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Info.plist:30`

Telemetry/analytics SDK indicators (`posthog`, `sentry`, `mixpanel`, `amplitude`, `segment`) were not found in code search.

### 4) Permission rationale analysis (browser secure-folder access)

Finding:
- Browser secure-folder and browser-keychain access occurs through `BrowserCookieService` for GitHub Copilot cookie extraction.
- This is used for:
  1. scraping `customerId` from GitHub billing HTML,
  2. querying Copilot usage card/table endpoints,
  3. history fetch.

Necessity assessment:
- **Partially justified** for rich Copilot billing/history retrieval from GitHub web endpoints.
- **Not strictly required** for all Copilot quota checks:
  - token-based Copilot quota path exists (`api.github.com/copilot_internal/user`) via `TokenManager.fetchCopilotPlanInfo(...)`.
  - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Services/TokenManager.swift:1956`
- Current behavior is **over-broad by default**:
  - provider managers fetch all providers, which can trigger cookie/keychain access even when user intent is unrelated.

### 5) Dependency risk triage (high-risk areas)

- `Sparkle` updater is enabled with automatic checks/downloads by default.
  - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/App/AppDelegate.swift:40`
  - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/App/AppDelegate.swift:41`
- Security APIs and local DB crypto/decryption are used in cookie/token discovery code paths (`Security`, `SQLite3`, `CommonCrypto`).
  - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Services/BrowserCookieService.swift:2`
  - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Services/BrowserCookieService.swift:3`
  - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Services/BrowserCookieService.swift:4`

## Risks Found (Ranked)

### High

1. **Over-broad default provider execution can trigger sensitive access unexpectedly.**
   - App path builds enabled provider list, but still calls `ProviderManager.fetchAll()` (all providers), then filters results afterward.
   - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/App/StatusBarController.swift:380`
   - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/App/StatusBarController.swift:401`
   - Impact: browser cookie/keychain access may occur even when user does not expect Copilot/browser-based checks.

### Medium

2. **Browser cookie/keychain access is default-on in Copilot flows.**
   - `BrowserCookieService` runs without explicit opt-in gate when Copilot provider executes.
   - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Providers/CopilotProvider.swift:45`
   - `upstream-opencode-bar/CopilotMonitor/CLI/Providers/CopilotCLIProvider.swift:25`

3. **CLI `status` command triggers all providers (including cookie path) by default.**
   - `upstream-opencode-bar/CopilotMonitor/CLI/main.swift:259`
   - `upstream-opencode-bar/CopilotMonitor/CLI/CLIProviderManager.swift:64`

4. **Extensive local process inspection/execution surfaces.**
   - Includes `ps`, `lsof`, `pkill`, and external CLI invocation.
   - Increases blast radius for misuse if input/control paths expand in future.

### Low

5. **Auto-update network behavior is enabled by default.**
   - No direct telemetry SDK observed, but updater network checks/downloads run automatically.

## Decision

- Phase 3 static review is complete.
- Browser secure-folder access is **explained** (cookie-based Copilot usage/history retrieval), but current default behavior is broader than least-privilege.
- Recommendation: **do not run dynamic phase yet** until high/medium least-privilege controls (P1-P3) are implemented and statically re-reviewed.

## Next Action

1. Execute `SAFE_PATCH_PLAN.md` in auditable save points (P1 -> P5).
2. Re-run static verification for P1-P3 security controls.
3. Reassess Phase 4 go/no-go after static mitigation evidence is documented.

## Static Mitigation Verification (P2 + P3)

- Verification timestamp (UTC): 2026-02-12 18:35:32Z
- Verification mode: static code-path review only

### P2 - Copilot sensitive gate (default off)

Evidence:
- Shared gate implemented in `TokenManager` with default-off setting key and CLI env override.
  - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Services/TokenManager.swift:522`
  - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Services/TokenManager.swift:568`
- App Copilot provider checks gate before browser-cookie path.
  - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Providers/CopilotProvider.swift:39`
  - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Providers/CopilotProvider.swift:48`
  - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Providers/CopilotProvider.swift:133`
- CLI Copilot provider now token-first and only enters browser-cookie path when gate is enabled.
  - `upstream-opencode-bar/CopilotMonitor/CLI/Providers/CopilotCLIProvider.swift:23`
  - `upstream-opencode-bar/CopilotMonitor/CLI/Providers/CopilotCLIProvider.swift:35`
  - `upstream-opencode-bar/CopilotMonitor/CLI/Providers/CopilotCLIProvider.swift:203`

Conclusion:
- Browser cookie access for Copilot is no longer unconditional.
- Default behavior is token-based unless explicitly enabled.

### P3 - CLI safe defaults and scope control

Evidence:
- CLI adds provider filtering and sensitive flags:
  - `--provider` (repeatable): `upstream-opencode-bar/CopilotMonitor/CLI/main.swift:279`
  - mutual exclusion check for `--allow-sensitive` and `--no-sensitive`: `upstream-opencode-bar/CopilotMonitor/CLI/main.swift:296`
  - per-command env gate propagation: `upstream-opencode-bar/CopilotMonitor/CLI/main.swift:301`, `upstream-opencode-bar/CopilotMonitor/CLI/main.swift:455`
- CLI manager supports selected-provider fetch path:
  - `upstream-opencode-bar/CopilotMonitor/CLI/CLIProviderManager.swift:73`
  - `upstream-opencode-bar/CopilotMonitor/CLI/CLIProviderManager.swift:82`
- `status` and `provider` commands now use scoped fetch where applicable:
  - `upstream-opencode-bar/CopilotMonitor/CLI/main.swift:327`
  - `upstream-opencode-bar/CopilotMonitor/CLI/main.swift:489`

Conclusion:
- CLI now supports explicit least-privilege fetch scope.
- Sensitive mode is explicit opt-in (`--allow-sensitive`), with safe default behavior.

## Phase 4 Readiness Decision (Post P2/P3 Static Check)

- Current status: **conditionally ready** for Phase 4 (optional dynamic analysis).
- Conditions before execution:
  1. Keep monitoring/blocking controls enabled during dynamic run.
  2. Use non-personal/no-cookie test environment as defined in root `AGENTS.md`.
  3. Capture dynamic evidence strictly into `DYNAMIC_FINDINGS.md`.

Rationale:
- Primary least-privilege gaps from Phase 3 (over-broad provider execution, unconditional Copilot cookie path, CLI all-provider default behavior) have now been mitigated in code and statically verified.

## Post-Implementation Static Verification Update (P4/P5)

- Verification timestamp (UTC): 2026-02-12 19:16:00Z
- Implementation checkpoint: `upstream-opencode-bar` commit `31dc685`

### P4 - Sensitive access audit logging

Evidence:
- Browser cookie debug logging redacts sensitive content and DB paths.
  - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Services/BrowserCookieService.swift`
- Copilot app/CLI provider logs explicitly indicate token-only vs sensitive-path selection.
  - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Providers/CopilotProvider.swift`
  - `upstream-opencode-bar/CopilotMonitor/CLI/Providers/CopilotCLIProvider.swift`
- Copilot plan parsing includes quota-source trace labels without exposing token/cookie content.
  - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Services/TokenManager.swift`

Conclusion:
- Sensitive-path decision visibility is improved while preserving redaction constraints.

### P5 - Transparency defaults

Evidence:
- App exposes `Security` submenu with update and sensitive-access state visibility and explicit Copilot fallback toggle.
  - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/App/StatusBarController.swift`
- User-facing docs now describe safe defaults and explicit opt-in behavior.
  - `upstream-opencode-bar/README.md`

Conclusion:
- Transparency and user control goals for P5 are implemented.

## Updated Decision

- Phase 3 + Phase 5 static security work is complete for planned hardening items P1-P5.
- Dynamic evidence has been captured in `DYNAMIC_FINDINGS.md`.
- Proceed to Phase 6 verification, packaging, and release-documentation gates.
