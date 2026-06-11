# GitHub Publication Checklist

Use this before the first public push.

## Required Checks

```sh
swift test
swift build
rg -n "AIza|YOUTUBE_API_KEY|oauth|cookie|password|secret|token" .
find . -type f \( -name "*.mp4" -o -name "*.mov" -o -name "*.m4v" -o -name "*.webm" -o -name "*.mkv" \) -print
```

Expected results:

- Tests pass.
- Secret scan returns only intentional documentation examples.
- Media scan returns nothing.

## Content Review

- `README.md` describes the current implementation, not future claims.
- `Config/*.example.json` contains schema-only placeholder metadata, not a concrete default YouTube URL or video ID.
- `Config/sources.json` is not committed.
- `Config/current-source.json` is not committed.
- No API keys, OAuth tokens, cookies, private URLs, local account names, or generated app bundles are committed.
- YouTube behavior is described as official embed playback, not frame extraction or wallpaper image generation.
- `docs/PRIVACY.md` describes the local file, WebView, YouTube playback, and AI-agent boundaries.

## Licensing

MIT License is selected in `LICENSE`.
Before changing the license or accepting external contributions, review the license intentionally.

## Release Readiness

Before a user-facing release, add:

- Signed `.app` packaging
- Hardened runtime and notarization notes
- App Sandbox entitlement review
- Network-client entitlement if sandboxed
- A privacy note explaining that YouTube playback is loaded in a non-persistent `WKWebView`
