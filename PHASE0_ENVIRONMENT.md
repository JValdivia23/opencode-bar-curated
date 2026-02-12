# Phase 0 Environment Note

- Timestamp (UTC): 2026-02-12 17:55:57Z
- OS: macOS 26.2 (build 25C56)
- Architecture: x86_64
- Shell: `/bin/zsh`
- Review strategy: pure static analysis first (no user switch, no VM)

## Install Source Findings

- `opencode-bar` install method: Homebrew cask
- Homebrew cask info: `opencode-bar 2.3.4`
- Cask source: `opgginc/homebrew-opencode-bar`
- Prior app artifact: `/Applications/OpenCode Bar.app`
- Prior linked binary: `/usr/local/bin/opencodebar`

## Important Distinction

- `opencode-bar` is separate from `opencode` CLI.
- `opencode` still exists at `/usr/local/bin/opencode` and points to `opencode-ai` npm global install (`/usr/local/lib/node_modules/opencode-ai/...`).
- This was not removed in Phase 1 because it is a different package than `opencode-bar`.
