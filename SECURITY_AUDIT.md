# Security Audit Report

**Project:** `opencode-bar-curated`  
**Base Upstream:** `opgginc/opencode-bar` v2.4.1 (commit `94c95d9`)  
**Audit Date:** February 12, 2026  
**Auditor:** Automated Agentic Security Review

---

## Executive Summary

This repository is a security-hardened fork of OpenCode Bar. The original application was audited for sensitive permission usage, specifically regarding browser cookie access and automatic updates.

**Key Findings:**
1.  **Browser Cookie Access:** The upstream application automatically accessed browser cookies (Chrome, Brave, Arc, Edge) to retrieve GitHub Copilot billing history without explicit user consent.
2.  **Automatic Updates:** The application checked for updates automatically by default.
3.  **Broad Permissions:** The CLI and app fetched data from all providers by default, triggering potential sensitive access paths.

**Hardening Actions:**
-   **P1: Provider Scoping:** Only enabled providers are fetched.
-   **P2: Copilot Sensitive Gate:** Browser cookie access for Copilot is now **disabled by default**. It requires explicit opt-in via "Security" settings or CLI flags.
-   **P3: CLI Safe Defaults:** The CLI now defaults to `--no-sensitive` mode.
-   **P4: Audit Logging:** Improved logging with redaction for sensitive data.
-   **P5: Transparency:** Added a "Security" menu to visualize and control sensitive permissions.

---

## Detailed Findings

### 1. Browser Profile & Secure Storage Access

**Finding:**
The upstream `BrowserCookieService` scanned directories for Chrome, Brave, Arc, and Edge to extract cookies and accessed the Keychain to decrypt them. This was used to fetch rich billing history for GitHub Copilot.

**Risk:**
Accessing browser cookies and keychain secrets without explicit user intent is a privacy risk.

**Mitigation (Applied):**
-   Created a "Sensitive Access Gate" in `TokenManager`.
-   Wrapped all cookie access logic in `CopilotProvider` and `CopilotCLIProvider` with a check for this gate.
-   Set the default state to **Disabled**.
-   Added a UI toggle in the "Security" menu for users who want to opt-in.
-   Added `--allow-sensitive` flag to the CLI.

### 2. Automatic Updates

**Finding:**
The Sparkle update framework was configured to automatically check for and download updates.

**Risk:**
Automatic execution of code from a remote source without user control.

**Mitigation (Applied):**
-   Disabled `SUEnableAutomaticChecks` and related keys in `Info.plist`.
-   Users must now manually "Check for Updates" via the menu.

### 3. CLI Default Behavior

**Finding:**
Running `opencodebar status` triggered fetch logic for all providers, potentially accessing sensitive paths (cookies) even if the user only wanted to check a token-based provider.

**Risk:**
Unintended activation of sensitive data access paths.

**Mitigation (Applied):**
-   CLI now defaults to "Safe Mode" (`--no-sensitive`).
-   Added `--provider` flag to scope execution to specific providers.
-   Requires explicit `--allow-sensitive` flag to bypass the safety gate.

---

## Verification

### Static Analysis
All code paths leading to `BrowserCookieService` and `Keychain` access were traced and guarded.

### Dynamic Verification (Phase 6)
-   **Safe Mode:** Verified that running `opencodebar status --provider copilot` **does not** trigger file system access to browser directories.
-   **Opt-in Mode:** Verified that `--allow-sensitive` successfully enables the legacy behavior for users who need it.

---

## Conclusion

This curated fork represents a "least privilege" approach to the OpenCode Bar utility. Functionality is preserved, but privacy-impacting features are now opt-in rather than default-on.
