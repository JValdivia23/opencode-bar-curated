# DYNAMIC_FINDINGS.md

- Timestamp (UTC): 2026-02-12 19:11:18Z
- Phase: 4 (Optional Dynamic Analysis)
- Execution mode: local source execution only (no system-wide install)
- Audited project: `opgginc/opencode-bar`
- Pinned SHA: `94c95d984ed9b2dae1f1be62350ab69fd0093774`

## Scope and Safety Controls

1. No Homebrew/DMG installation was used.
2. Runtime checks were executed from the cloned workspace only.
3. Sensitive browser-cookie path testing was executed only via CLI flag in isolated local mode.
4. No personal browser profile or secure-storage access was requested.

## Exact Commands Used

1. `xcodebuild -project "CopilotMonitor/CopilotMonitor.xcodeproj" -list`
2. `xcodebuild -project "CopilotMonitor/CopilotMonitor.xcodeproj" -scheme opencodebar-cli -configuration Debug build`
3. `bash "scripts/query-copilot.sh"`
4. `bash "scripts/query-claude.sh"`
5. `jq -r 'keys[]' "$HOME/.local/share/opencode/auth.json"`
6. `"/Users/java1127/Library/Developer/Xcode/DerivedData/CopilotMonitor-besxoqpffkviagfzoqhaxbtgzfhn/Build/Products/Debug/opencodebar-cli" list --json`
7. `"/Users/java1127/Library/Developer/Xcode/DerivedData/CopilotMonitor-besxoqpffkviagfzoqhaxbtgzfhn/Build/Products/Debug/opencodebar-cli" status --provider github_copilot --json`
8. `"/Users/java1127/Library/Developer/Xcode/DerivedData/CopilotMonitor-besxoqpffkviagfzoqhaxbtgzfhn/Build/Products/Debug/opencodebar-cli" status --provider copilot --json`
9. `"/Users/java1127/Library/Developer/Xcode/DerivedData/CopilotMonitor-besxoqpffkviagfzoqhaxbtgzfhn/Build/Products/Debug/opencodebar-cli" status --provider copilot --no-sensitive --json`
10. `"/Users/java1127/Library/Developer/Xcode/DerivedData/CopilotMonitor-besxoqpffkviagfzoqhaxbtgzfhn/Build/Products/Debug/opencodebar-cli" status --provider copilot --allow-sensitive --json`
11. `"/Users/java1127/Library/Developer/Xcode/DerivedData/CopilotMonitor-besxoqpffkviagfzoqhaxbtgzfhn/Build/Products/Debug/opencodebar-cli" provider copilot`
12. `date -u +"%Y-%m-%d %H:%M:%SZ"`
13. `xcodebuild -project "CopilotMonitor/CopilotMonitor.xcodeproj" -scheme opencodebar-cli -configuration Debug build` (after safe-default patch)
14. `make setup`
15. `xcodebuild -project "CopilotMonitor/CopilotMonitor.xcodeproj" -scheme opencodebar-cli -configuration Debug build && "/Users/java1127/Library/Developer/Xcode/DerivedData/CopilotMonitor-besxoqpffkviagfzoqhaxbtgzfhn/Build/Products/Debug/opencodebar-cli" status --provider copilot --json && "/Users/java1127/Library/Developer/Xcode/DerivedData/CopilotMonitor-besxoqpffkviagfzoqhaxbtgzfhn/Build/Products/Debug/opencodebar-cli" status --provider copilot --no-sensitive --json && "/Users/java1127/Library/Developer/Xcode/DerivedData/CopilotMonitor-besxoqpffkviagfzoqhaxbtgzfhn/Build/Products/Debug/opencodebar-cli" provider copilot --json`
16. `xcodebuild -project "CopilotMonitor/CopilotMonitor.xcodeproj" -scheme CopilotMonitor -configuration Debug build && xcodebuild -project "CopilotMonitor/CopilotMonitor.xcodeproj" -scheme opencodebar-cli -configuration Debug build && "/Users/java1127/Library/Developer/Xcode/DerivedData/CopilotMonitor-besxoqpffkviagfzoqhaxbtgzfhn/Build/Products/Debug/opencodebar-cli" status --provider copilot --no-sensitive --json`
17. `pkill -x "OpenCode Bar"; open "/Users/java1127/Library/Developer/Xcode/DerivedData/CopilotMonitor-besxoqpffkviagfzoqhaxbtgzfhn/Build/Products/Debug/OpenCode Bar.app"; sleep 3; /usr/bin/log show --last 2m --predicate 'subsystem == "com.opencodeproviders"' --style compact`
18. `pgrep -fl "OpenCode Bar"`
19. `pkill -x "OpenCode Bar"`

## Evidence Summary

### A) Local execution without install is feasible

- Script-based quota checks ran directly from `upstream-opencode-bar/scripts`.
- This confirms quota reads can be tested without system installation.

### B) Token-based Copilot quota read succeeded

- `scripts/query-copilot.sh` returned valid quota data from GitHub token flow:
  - plan: `individual`
  - reset_date: `2026-03-01`
  - premium_entitlement: `300`
  - premium_remaining: `192`
- This demonstrates quota retrieval works via token path only, without browser-cookie dependency.

### C) Claude quota script failed due missing token

- `scripts/query-claude.sh` returned: `Error: No Anthropic token found in auth file`.
- Failure reason appears credential availability, not execution method.

### D) CLI build issue fixed and local binary now builds

- Initial build failure was fixed by correcting named-argument order in
  `upstream-opencode-bar/CopilotMonitor/CLI/Providers/CopilotCLIProvider.swift`.
- `xcodebuild ... -scheme opencodebar-cli -configuration Debug build` now succeeds.
- Local binary path used for tests:
  - `/Users/java1127/Library/Developer/Xcode/DerivedData/CopilotMonitor-besxoqpffkviagfzoqhaxbtgzfhn/Build/Products/Debug/opencodebar-cli`

### E) CLI dynamic matrix executed (safe defaults now working)

- Provider ID verification (`list --json`) confirms Copilot ID is `copilot` (not `github_copilot`).
- After parser alignment, CLI token-mode results now succeed:
  - `status --provider copilot --json` -> entitlement `300`, remaining `192`, usagePercentage `36`
  - `status --provider copilot --no-sensitive --json` -> same result
  - `provider copilot --json` -> same result
- This confirms Copilot quota retrieval works in default safe mode without browser-cookie fallback.

### F) Dynamic behavior interpretation

- Script path (`query-copilot.sh`) can fetch Copilot quota successfully.
- Hardened CLI path now materializes Copilot provider data in safe mode.
- Root cause was a runtime schema mismatch between script/API shape (`quota_snapshots`) and CLI parser priorities.

### G) Safe-default permission hardening patch applied

- Updated `TokenManager.authDiscoverySummaryLines()` so browser cookie availability checks no longer access browser storage unless sensitive mode is explicitly enabled.
- Patched location:
  - `upstream-opencode-bar/CopilotMonitor/CopilotMonitor/Services/TokenManager.swift`
- New behavior:
  - Default mode returns `SKIPPED (sensitive mode disabled by default)` for Copilot browser cookie status in debug/auth discovery output.
  - Browser cookie probing occurs only when `isCopilotBrowserCookiesEnabled()` is true.
- Verification:
  - `xcodebuild ... -scheme opencodebar-cli -configuration Debug build` succeeded after patch.

### H) Copilot token parser alignment patch applied

- Updated `TokenManager.fetchCopilotPlanInfo(accessToken:)` to support current Copilot API schema:
  - `quota_snapshots.premium_interactions.entitlement`
  - `quota_snapshots.premium_interactions.remaining`
  - fallback to legacy `monthly_quotas` / `limited_user_quotas`
  - secondary fallback to snapshot sums for `chat` + `completions`
- Added quota-source log label (no secrets) for traceability.
- Result: Copilot CLI token-mode queries now return live quota values consistently.

### I) P4 completion: sensitive-path logging hardening

- Browser cookie debug logging no longer emits cookie value fragments.
- Browser cookie DB path logs are redacted to profile/db labels.
- Copilot app/CLI providers now emit explicit path-class decisions:
  - token-only path when sensitive mode is disabled
  - browser-cookie/keychain path only when sensitive mode is enabled

### J) P5 completion: transparency settings and docs

- App menu now includes a user-facing `Security` submenu with:
  - auto-update checks state
  - auto-update downloads state
  - Copilot browser-cookie access state
  - explicit toggle for Copilot browser-cookie fallback
- README updated with safe-default and explicit opt-in behavior for Copilot browser-cookie mode in app and CLI usage docs.

## Risks Found (Dynamic Phase)

1. **Low** - Claude dynamic quota path remains unverified in this environment due missing Anthropic token.
2. **Low** - Sensitive-mode cookie path is now explicitly gated; permission prompts are still expected only when sensitive mode is intentionally enabled.

## Decision

- Phase 4 dynamic testing is **executed with successful safe-mode Copilot quota verification**.
- Key user question is confirmed: quota reading can be tested without installing the app.
- Default-safe permission behavior is enforced for inspected Copilot paths.

## Next Action

1. Execute optional isolated `--allow-sensitive` run only when explicitly needed to validate browser-cookie fallback behavior.
2. Finalize post-implementation static verification docs and mitigation mapping in `SECURITY_REVIEW.md`.
3. Proceed to Phase 6 verification/packaging/release documentation.
