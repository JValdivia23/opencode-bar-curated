# PLAN.md

## Project Evolution

**Original Goal (COMPLETE):** Uninstall, audit, and produce a hardened local version of `opgginc/opencode-bar`.





- ✅ Uninstalled original version and verified clean removal
- ✅ Cloned and audited upstream `opgginc/opencode-bar` v2.4.1 (SHA: 94c95d9)
- ✅ Completed static security review - findings documented
- ✅ Applied hardening patches P1-P5
- ✅ Built and installed curated version locally
- ✅ All tests passing (47/47)
- ✅ CLI functional and verified

- Browser cookie access enabled by default → **Hardened:** Disabled by default, explicit opt-in
- Automatic updates from upstream → **Hardened:** Disabled, user-controlled
- Sensitive permissions not documented → **Hardened:** Added transparency and documentation

- `PHASE0_ENVIRONMENT.md` - Environment baseline
- `PHASE1_UNINSTALL_REPORT.md` - Uninstall verification
- `AUDIT_BASELINE.md` - Pinned SHA and trust snapshot
- `SECURITY_REVIEW.md` - Static findings
- `DYNAMIC_FINDINGS.md` - Runtime verification
- `SAFE_PATCH_PLAN.md` - Hardening design
- Curated build: `upstream-opencode-bar` commit `b4d99a9`



- **Name:** `opencode-bar-curated`
- **URL:** `https://github.com/JValdivia23/opencode-bar-curated`
- **Type:** Public repository (MIT License maintained)
- **Purpose:** Security-audited fork with hardened permissions
- **Distribution:** Homebrew cask + Direct DMG download

- **Versioning:** Start fresh at `v1.0.0` (indicates curated fork)
- **Updates:** Disabled by default, manual check available
- **Code Signing:** Ad-hoc only (no Apple Developer ID)
- **Sparkle:** No signing key (updates disabled for now)
- **Security Contact:** jairo.valdiviaprado@colorado.edu
- **Attribution:** Clear credit to upstream `opgginc/opencode-bar`






   - [ ] Change `SUEnableAutomaticChecks` to `false`
   - [ ] Update `SUFeedURL` to `https://github.com/JValdivia23/opencode-bar-curated/releases/latest/download/appcast.xml`
   - [ ] Update `CFBundleShortVersionString` to `1.0.0`
   - [ ] Update `CFBundleVersion` to `1.0.0`
   - [ ] Add comment: `<!-- Auto-updates disabled until repository releases are configured -->`

   - [ ] Line 1761: Update "View on GitHub" URL to `https://github.com/JValdivia23/opencode-bar-curated`
   - [ ] Line 1937: Update "Report Issue" URL to `https://github.com/JValdivia23/opencode-bar-curated/issues/new`
   - [ ] Line 1965: Update additional GitHub reference

   - [ ] Add security audit badge and notice at top
   - [ ] Update all `opgginc/opencode-bar` references to `JValdivia23/opencode-bar-curated`
   - [ ] Update Homebrew installation: `brew tap JValdivia23/opencode-bar-curated`
   - [ ] Add "🔒 Security Audit" section explaining fork purpose
   - [ ] Update Credits section with upstream attribution
   - [ ] Add link to `SECURITY_AUDIT.md`

   - [ ] `build-release.yml`: Update download URLs (2 locations)
   - [ ] `manual-release.yml`: Update download URLs (2 locations)
   - [ ] Update appcast.xml links in both workflows

   - [ ] Update `repository.url` to new repo
   - [ ] Update `bugs.url` to new issues page
   - [ ] Update `homepage` to new repo


   - [ ] Overview of audit scope and methodology
   - [ ] Findings summary (safe behaviors + concerns)
   - [ ] Applied hardening patches P1-P5 with code references
   - [ ] Verification results (tests, runtime checks)
   - [ ] Differences from upstream table
   - [ ] Installation & security best practices
   - [ ] Security contact: jairo.valdiviaprado@colorado.edu
   - [ ] License & attribution section
   - [ ] Changelog entry for v1.0.0-curated


- [ ] `PLAN.md` (this file - audit workspace planning)
- [ ] `PHASE0_ENVIRONMENT.md`
- [ ] `PHASE1_UNINSTALL_REPORT.md`
- [ ] `AUDIT_BASELINE.md`
- [ ] `SECURITY_REVIEW.md`
- [ ] `DYNAMIC_FINDINGS.md`
- [ ] `SAFE_PATCH_PLAN.md`
- [ ] Root `AGENTS.md` (audit workspace version)
- [ ] `upstream-opencode-bar/AGENTS.md` (coding guidelines)
- [ ] `upstream-opencode-bar/AGENTS-design-decisions.md`

- [x] `LICENSE` (required by MIT)
- [x] `README.md` (updated for curated fork)
- [x] `SECURITY_AUDIT.md` (new)
- [x] `.gitignore`
- [x] `.github/` (workflows, updated)
- [x] `CopilotMonitor/` (source code)
- [x] `scripts/` (helper scripts)
- [x] `docs/` (screenshots, API docs)


  ```
  Initial commit: Security-audited fork of opgginc/opencode-bar v2.4.1
  
  - Applied hardening patches P1-P5
  - Disabled browser cookie access by default (explicit opt-in)
  - Disabled automatic updates (manual check available)
  - Updated all repository references
  - Added SECURITY_AUDIT.md with audit findings
  - Fresh versioning: v1.0.0
  
  Based on upstream commit: 94c95d9
  Audit date: 2026-02-12 UTC
  Security contact: jairo.valdiviaprado@colorado.edu
  ```


- [ ] Create new repository `opencode-bar-curated` at https://github.com/JValdivia23
- [ ] Set description: "Security-audited and hardened fork of OpenCode Bar - AI provider usage monitor for macOS"
- [ ] Add topics: `macos`, `menubar-app`, `ai`, `opencode`, `security-audit`, `swift`, `sparkle`
- [ ] Enable Issues
- [ ] Enable Releases
- [ ] Disable Wiki, Projects, Discussions
- [ ] Allow forking
- [ ] Public visibility

- [ ] `git remote add origin https://github.com/JValdivia23/opencode-bar-curated.git`
- [ ] `git push -u origin main`






- [ ] Create new repository `homebrew-opencode-bar-curated`
- [ ] Description: "Homebrew tap for opencode-bar-curated"
- [ ] Public visibility
- [ ] Initialize with README



  - Version: `1.0.0`
  - SHA256: `PLACEHOLDER` (will update after first release)
  - Download URL pointing to GitHub releases
  - App name, description, homepage
  - Zap trash locations





































- [x] Original install removed
- [x] Security review complete with findings documented
- [x] Hardening patches applied and tested
- [x] Local curated version installed and functional

- [ ] Public repository created at `JValdivia23/opencode-bar-curated`
- [ ] All code references updated to curated repo
- [ ] SECURITY_AUDIT.md published with findings
- [ ] Homebrew tap created and functional
- [ ] v1.0.0 release published with DMG
- [ ] Installation tested via both Homebrew and direct download

- [ ] Update monitoring process established
- [ ] Security reporting channel active
- [ ] Repository maintenance plan documented



- API tokens and authentication credentials
- Browser sessions and cookies
- Local secrets and configuration files
- User privacy and usage data

- ✅ Browser secure-folder access (disabled by default)
- ✅ Automatic untrusted updates (disabled)
- ✅ Undocumented sensitive permissions (now transparent)
- ✅ Token leakage through logs (redacted)

- ⚠️ Ad-hoc code signing (users must bypass Gatekeeper manually)
- ⚠️ No auto-update mechanism (manual update process required)
- ⚠️ Dependency vulnerabilities (periodic audit recommended)







