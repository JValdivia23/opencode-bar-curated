cask 'opencode-bar-curated' do
  version '1.0.0'

  # Placeholder sha256 — replace with the real SHA256 of the DMG from the v1.0.0 GitHub release
  sha256 'PLACEHOLDER_SHA256'

  url "https://github.com/JValdivia23/opencode-bar-curated/releases/download/v#{version}/OpenCodeBar-#{version}.dmg"
  name 'OpenCode Bar (curated)'
  desc 'Curated and security-hardened OpenCode Bar'
  homepage 'https://github.com/JValdivia23/opencode-bar-curated'

  app 'OpenCode Bar.app'
  binary '/usr/local/bin/opencodebar', target: 'opencodebar'

  zap trash: [
    '~/Library/Application Support/OpenCode Bar',
    '~/Library/Preferences/com.opencodebar.plist'
  ]
end
