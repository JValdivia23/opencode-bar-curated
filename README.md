# OpenCode Bar

<p align="center">
  <img src="docs/screenshot-subscription.png" alt="OpenCode Bar Screenshot" width="40%">
  <img src="docs/screenshot3.png" alt="OpenCode Bar Screenshot" width="40%">
</p>

<p align="center">
  <strong>Automatically monitor all your AI provider usage from OpenCode in real-time from the macOS menu bar.</strong>
</p>

<p align="center">
  <a href="https://github.com/JValdivia23/opencode-bar-curated/releases/latest">
    <img src="https://img.shields.io/github/v/release/JValdivia23/opencode-bar-curated?style=flat-square" alt="Release">
  </a>
  <a href="https://github.com/JValdivia23/opencode-bar-curated/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/JValdivia23/opencode-bar-curated?style=flat-square" alt="License">
  </a>
  <a href="https://github.com/JValdivia23/opencode-bar-curated/blob/main/SECURITY_AUDIT.md">
    <img src="https://img.shields.io/badge/security-audited-green?style=flat-square" alt="Security Audit">
  </a>
  <img src="https://img.shields.io/badge/platform-macOS%2013%2B-blue?style=flat-square" alt="Platform">
  <img src="https://img.shields.io/badge/swift-5.9-orange?style=flat-square" alt="Swift">
</p>

> 🔒 **Security-Audited Fork**: This is a curated, security-hardened version of OpenCode Bar with disabled-by-default sensitive permissions and explicit opt-in for browser cookie access. See [SECURITY_AUDIT.md](SECURITY_AUDIT.md) for details.

---

## Installation

### Homebrew (Easy)

```bash
brew tap JValdivia23/opencode-bar-curated
brew install --cask opencode-bar-curated
```

> **Note:** Since this app is ad-hoc signed, macOS Gatekeeper may block the first launch. 
> To open it:
> 1. Right-click "OpenCode Bar.app" in Applications
> 2. Select "Open"
> 3. Click "Open" in the dialog


### Download

Download the latest `.dmg` file from the [**Releases**](https://github.com/JValdivia23/opencode-bar-curated/releases/latest) page.

## Overview

**OpenCode Bar** automatically detects and monitors all AI providers registered in your [OpenCode](https://opencode.ai) configuration. No manual setup required - just install and see your usage across all providers in one unified dashboard.

### Supported Providers (Auto-detected from OpenCode)

| Provider | Type | Key Metrics |
|----------|------|-------------|
| **OpenRouter** | Pay-as-you-go | Credits balance, daily/weekly/monthly cost |
| **OpenCode Zen** | Pay-as-you-go | Daily history (30 days), model breakdown |
| **GitHub Copilot Add-on** | Pay-as-you-go | Usage-based billing after exceeding quota |
| **Claude** | Quota-based | 5h/7d usage windows, Sonnet/Opus breakdown |
| **Codex** | Quota-based | Primary/Secondary quotas, plan type |
| **Gemini CLI** | Quota-based | Per-model quotas, multi-account support with email labels and account ID details |
| **Kimi for Coding (Kimi K2.5)** | Quota-based | Usage limits, membership level, reset time |
| **Z.AI Coding Plan** | Quota-based | Token/MCP quotas, model usage, tool usage (24h) |
| **Synthetic** | Quota-based | 5h usage limit, request limits, reset time |
| **Antigravity** | Quota-based | Local language server monitoring |
| **Chutes AI** | Quota-based | Daily quota limits (300/2000/5000), credits balance |
| **GitHub Copilot** | Quota-based | Daily history, overage tracking |

### OpenCode Plugins
- **Antigravity/Gemini**
  - `NoeFabris/opencode-antigravity-auth` (writes `~/.config/opencode/antigravity-accounts.json`)
  - `jenslys/opencode-gemini-auth` (writes `google.oauth` in OpenCode `auth.json`)
  - Gemini CLI OAuth creds (writes `~/.gemini/oauth_creds.json` for email/account ID metadata; overlaps are merged with Antigravity accounts)
- **Claude**: `anomalyco/opencode-anthropic-auth`

### Standalone tools
- **Codex**: `Soju06/codex-lb` (writes `~/.codex-lb/`)

### Other AI agents beyond OpenCode that supports auto-detection
- **Codex**
  - **Codex for Mac** - Auto-detected through `~/.codex/auth.json`
  - **Codex CLI** - Auto-detected through `~/.codex/auth.json`
- **Claude Code CLI** - Keychain-based authentication detection

## Features

### Automatic Provider Detection
- **Zero Configuration**: Reads your OpenCode `auth.json` automatically
- **Multi-path Support**: Searches `$XDG_DATA_HOME/opencode`, `~/.local/share/opencode`, and `~/Library/Application Support/opencode`
- **Dynamic Updates**: New providers appear as you add them to OpenCode
- **Smart Categorization**: Pay-as-you-go vs Quota-based providers displayed separately

### Real-time Monitoring
- **Menu Bar Dashboard**: View all provider usage at a glance
- **Visual Indicators**: Color-coded progress (green → yellow → orange → red)
- **Detailed Submenus**: Click any provider for in-depth metrics
- **Auth Source Labels**: See where each account token was detected (OpenCode, VS Code, Keychain, etc.)
- **Gemini Account Labels**: Shows `Gemini CLI (email)` when email is available, with fallback to `Gemini CLI #N`

### Usage History & Predictions
- **Daily Tracking**: View request counts and overage costs
- **EOM Prediction**: Estimates end-of-month totals using weighted averages
- **Add-on Cost Tracking**: Shows additional costs when exceeding limits

### Subscription Settings (Quota-based Providers Only)
- **Per-Provider Plans**: Configure your subscription tier for quota-based providers
- **Cost Tracking**: Accurate monthly cost calculation based on your plan
- **Orphaned Plan Cleanup**: Detect and reset stale subscription entries that no longer match accounts

### Convenience
- **Launch at Login**: Start automatically with macOS
- **Parallel Fetching**: All providers update simultaneously for speed
- **Auto Updates**: Seamless background updates via Sparkle framework

### Security Settings
- **Security Menu**: Open the `Security` submenu from the menu bar app to review update and sensitive-access states
- **Default Safe Mode**: Copilot uses token-only mode by default
- **Explicit Opt-in**: Browser-cookie fallback for Copilot is disabled by default and must be enabled manually

## Development

### Build from Source

```bash
# Clone the repository
git clone https://github.com/JValdivia23/opencode-bar-curated.git
cd opencode-bar-curated

# Build
xcodebuild -project CopilotMonitor/CopilotMonitor.xcodeproj \
  -scheme CopilotMonitor -configuration Debug build

# Open the app (auto-detect path)
open "$(xcodebuild -project CopilotMonitor/CopilotMonitor.xcodeproj -scheme CopilotMonitor -configuration Debug -showBuildSettings 2>/dev/null | sed -n 's/^[[:space:]]*BUILT_PRODUCTS_DIR = //p' | head -n 1)/OpenCode Bar.app"
```

**Requirements:**
- macOS 13.0+
- Xcode 15.0+ (for building from source)
- [OpenCode](https://opencode.ai) installed with authenticated providers

## Usage

### Menu Bar App

1. **Install OpenCode**: Make sure you have OpenCode installed and authenticated with your providers
2. **Launch the app**: Run OpenCode Bar
3. **View usage**: Click the menu bar icon to see all your provider usage
4. **GitHub Copilot** (optional): Token-based quota works by default; browser-cookie fallback (Chrome, Brave, Arc, Edge) is explicit opt-in in `Security`

### Command Line Interface (CLI)

OpenCode Bar includes a powerful CLI for querying provider usage programmatically.

#### Installation

If you installed via Homebrew, the `opencodebar` command is already available in your path.

Otherwise, you can install the CLI manually:

```bash
# Option 1: Install via menu bar app
# Click "Install CLI" from the Settings menu

# Option 2: Manual symlink
ln -s "/Applications/OpenCode Bar.app/Contents/MacOS/opencodebar-cli" /usr/local/bin/opencodebar

# Verify installation
opencodebar --help
```

#### Commands

The CLI defaults to "Safe Mode" (`--no-sensitive`), which means it will **not** attempt to access browser cookies or other sensitive data sources unless explicitly requested.

```bash
# Show all providers and their usage (default command, safe mode)
opencodebar status

# Query selected provider only (recommended for least privilege)
opencodebar status --provider copilot

# Enable browser-cookie fallback for Copilot (requires explicit flag)
opencodebar status --provider copilot --allow-sensitive

# List all available providers
opencodebar list

# Get detailed info for a specific provider
opencodebar provider claude
opencodebar provider gemini_cli

# Output as JSON (for scripting)
opencodebar status --json
opencodebar status --provider copilot --json
opencodebar status --provider copilot --allow-sensitive --json
```

#### Table Output Example

```bash
$ opencodebar
Provider            Refresh                           Usage     Key Metrics
──────────────────────────────────────────────────────────────────────────────────────────
Antigravity         Claude: in 5d (02/17)             60%       40/100 remaining
                    Gemini: in 2h (18:20)             0%        100/100 remaining
ChatGPT             Weekly: in 5d (02/18)             100%      0/100 remaining
Gemini CLI          -                                 0%        100/100 remaining
GitHub Copilot      Monthly: in 16d (02/28)           37%       189/300 remaining
OpenCode Zen        -                                 -         $0.00 spent
OpenRouter          -                                 -         $0.00 spent
```

#### JSON Output Example

```bash
$ opencodebar status --json
{
  "claude": {
    "type": "quota-based",
    "remaining": 23,
    "entitlement": 100,
    "usagePercentage": 77,
    "overagePermitted": false
  },
  "gemini_cli": {
    "type": "quota-based",
    "remaining": 85,
    "entitlement": 100,
    "usagePercentage": 15,
    "overagePermitted": false,
    "accounts": [
      {
        "index": 0,
        "email": "user1@gmail.com",
        "accountId": "100663739661147150906",
        "remainingPercentage": 100,
        "modelBreakdown": {
          "gemini-2.5-pro": 100,
          "gemini-2.5-flash": 100
        }
      },
      {
        "index": 1,
        "email": "user2@company.com",
        "accountId": "109876543210987654321",
        "remainingPercentage": 85,
        "modelBreakdown": {
          "gemini-2.5-pro": 85,
          "gemini-2.5-flash": 90
        }
      }
    ]
  },
  "openrouter": {
    "type": "pay-as-you-go",
    "cost": 37.42
  }
}
```

#### Use Cases

- **Monitoring**: Integrate with monitoring systems to track API usage
- **Automation**: Build scripts that respond to quota thresholds
- **CI/CD**: Check provider quotas before running expensive operations
- **Reporting**: Generate usage reports for billing and analysis

#### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Authentication failed |
| 3 | Network error |
| 4 | Invalid arguments |

### Menu Structure

```
─────────────────────────────
Pay-as-you-go: $37.61
  OpenRouter       $37.42    ▸
  OpenCode Zen     $0.19     ▸
─────────────────────────────
Quota Status: $219/m
  Copilot          0%        ▸
  Claude: 60%, 100%          ▸
  Codex            100%      ▸
  Z.AI Coding Plan 99%       ▸
  Gemini CLI (user1@gmail.com) 100% ▸
─────────────────────────────
Predicted EOM: $451
─────────────────────────────
Refresh (⌘R)
Auto Refresh              ▸
Settings                  ▸
─────────────────────────────
Version 2.1.0
Quit (⌘Q)
```

#### Menu Group Titles

| Group | Format | Description |
|-------|--------|-------------|
| **Pay-as-you-go** | `Pay-as-you-go: $XX.XX` | Sum of all pay-as-you-go provider costs (OpenRouter + OpenCode Zen) |
| **Quota Status** | `Quota Status: $XXX/m` | Shows total monthly subscription cost if any quota-based providers have subscription settings configured. If no subscriptions are set, shows just "Quota Status". |

> **Note**: Subscription settings are only available for quota-based providers. Pay-as-you-go providers do not have subscription options since they charge based on actual usage.

## How It Works

1. **Token Discovery**: Reads authentication tokens from OpenCode's `auth.json` (with multi-path fallback)
2. **Cookie Detection**: Finds GitHub Copilot sessions from Chrome, Brave, Arc, or Edge (with profile support)
3. **Parallel Fetching**: Queries all provider APIs simultaneously
4. **Smart Caching**: Falls back to cached data on network errors
5. **Graceful Degradation**: Shows available providers even if some fail

### Privacy & Security

- **Local Only**: All data stays on your machine
- **No Third-party Servers**: Direct communication with provider APIs
- **Read-only Access**: Uses existing OpenCode tokens (no additional permissions)
- **Browser Cookie Access (Copilot)**: Disabled by default and available only through explicit opt-in
- **Security Transparency**: The app surfaces auto-update check/download state and Copilot sensitive-access state in the `Security` submenu

## Troubleshooting

### "No providers found" or auth.json not detected
The app searches for `auth.json` in these locations (in order):
1. `$XDG_DATA_HOME/opencode/auth.json` (if XDG_DATA_HOME is set)
2. `~/.local/share/opencode/auth.json` (default)
3. `~/Library/Application Support/opencode/auth.json` (macOS fallback)

### GitHub Copilot not showing
- Default mode reads Copilot quota from token sources and does not require browser access
- If you need browser-cookie fallback, enable it from the app `Security` submenu or CLI `--allow-sensitive`
- For fallback mode, make sure you're signed into GitHub in a supported browser (Chrome, Brave, Arc, or Edge)

### OpenCode CLI commands failing
The app dynamically searches for the `opencode` binary in:
- Current PATH (`which opencode`)
- Login shell PATH
- Common install locations: `~/.opencode/bin/opencode`, `/usr/local/bin/opencode`, etc.

## Contributing

Contributions are welcome! Please submit a Pull Request.

### Development Setup

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. **Setup Git Hooks** (run once after clone):
   ```bash
   make setup
   ```
   This configures pre-commit hooks for:
   - **SwiftLint**: Checks Swift code style on staged `.swift` files
   - **action-validator**: Validates GitHub Actions workflow files
4. Make your Changes
5. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
   - Pre-commit hooks will automatically check your code
   - Fix any violations or use `git commit --no-verify` to bypass (not recommended)
6. Push to the Branch (`git push origin feature/AmazingFeature`)
7. Open a Pull Request

### Code Quality

This project uses SwiftLint and action-validator to maintain code quality:

- **Pre-commit Hook**: Runs on `git commit` (setup via `make setup`)
  - SwiftLint for `.swift` files
  - action-validator for `.github/workflows/*.yml` files
- **GitHub Actions**: Runs on all pushes and pull requests
- **Manual Check**: `make lint` (or `make lint-swift`, `make lint-actions`)

## License

MIT License - See [LICENSE](LICENSE) file for details.

## Related

- [OpenCode](https://opencode.ai) - The AI coding assistant that powers this monitor
- [GitHub Copilot](https://github.com/features/copilot)

## Credits

- [OP.GG](https://op.gg)
- [Sangrak Choi](https://kargn.as)

---

<p align="center">
  Made with tiredness for AI power users
</p>
