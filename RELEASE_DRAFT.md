Release v1.0.0 Draft Checklist

1. Build unsigned DMG
   - Xcode: Archive the app, export as macOS App and create a DMG named `OpenCodeBar-1.0.0.dmg`.

2. Compute SHA256
   - `shasum -a 256 OpenCodeBar-1.0.0.dmg` -> use the hex digest in the Homebrew cask `sha256`.

3. Create GitHub release
   - Tag: `v1.0.0`
   - Attach: `OpenCodeBar-1.0.0.dmg` and `appcast.xml` (if re-enabling Sparkle later).

4. Update Homebrew cask
   - Replace `PLACEHOLDER_SHA256` in `homebrew-opencode-bar-curated/Casks/opencode-bar-curated.rb` with the real SHA.
   - Create PR to `homebrew-opencode-bar-curated` or the official Homebrew cask repo as desired.

5. Post-release QA
   - Install via the cask on a clean macOS VM and verify App/CLI functionality.
