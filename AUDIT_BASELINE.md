# AUDIT_BASELINE.md

## Audit Scope

- Project: `opgginc/opencode-bar`
- Audit start (UTC): 2026-02-12 17:59:08Z
- Local clone path: `/Users/java1127/Library/CloudStorage/OneDrive-UCB-O365/Projects/opencode-bar/upstream-opencode-bar`
- Review mode: static-analysis-first (no runtime execution of untrusted code)

## Repository Identity

- Remote URL (origin): `https://github.com/opgginc/opencode-bar.git`
- Default branch: `main`
- Current audited commit (pinned SHA): `94c95d984ed9b2dae1f1be62350ab69fd0093774`
- Commit summary: `chore: bump version to v2.4.1` (2026-02-12 17:21:45 +0000)
- Local review branch created: `audit/security-baseline-2026-02-12`

## Trust Signals Collected

- GitHub repository: `https://github.com/opgginc/opencode-bar`
- Visibility: public
- Stars/Forks at capture time: 143 / 9
- Open issues at capture time: 3
- Latest release: `v2.4.1` published 2026-02-12T17:21:50Z
- Recent tags observed: `v2.4.1`, `v2.4.0`, `v2.3.4`, `v2.3.3`, `v2.3.2`

## Issue Snapshot (Security-Relevant Quick Pass)

- Open issues are feature/UX focused (no explicit browser-secure-folder warning in open list).
- Keyword search across issues (`permission`, `browser`, `auth.json`) found mostly closed bug reports related to provider/auth behavior.
- Conclusion for Phase 2: no immediate public issue indicating clear malicious behavior, but this is not sufficient for trust.

## Dependency/Lockfile Snapshot

- Root has `package.json` for CI tooling.
- SwiftPM lock exists at:
  - `CopilotMonitor/CopilotMonitor.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`
- No root `package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`, or `bun.lock*` found.

## Phase 2 Outcome

- Phase 2 complete.
- Baseline commit pinned for audit reproducibility.
- Ready to begin Phase 3 static security review, starting from quota command path and sensitive file access mapping.
