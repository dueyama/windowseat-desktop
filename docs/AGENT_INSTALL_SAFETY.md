# Agent Install And Code Safety Checklist

This document is for Codex, Claude, or another local agent installing or running WindowSeat from the README.

The user should be able to ask for installation with a short request. The agent owns the code inspection, safety checks, local setup, source curation, and launch steps.

This checklist is especially important for forks, mirrors, pull requests, downloaded archives, or any checkout whose contents may differ from the trusted upstream repository. It is not a claim that the reference implementation is unsafe; it is a guard against running unfamiliar code blindly.

## Before Running Code

Read:

1. `README.md`
2. `AGENTS.md`
3. `docs/AI_AGENT_CURATOR.md`
4. `docs/YOUTUBE_POLICY.md`
5. `docs/PORTING_CONCEPT.md` when the target is not macOS

Inspect the implementation before executing scripts or opening the app:

- `Package.swift`
- `Sources/`
- `scripts/`
- `Config/*.example.json`
- `.gitignore`

For forks or unknown checkouts, compare with the trusted upstream when possible. Do not run scripts blindly if they have changed in a way that affects privacy, networking, credentials, media storage, filesystem writes, process control, launch agents, shell startup files, or browser/app automation.

## Code Safety Checks

Run these before public sharing or before trusting a fresh checkout:

```sh
swift test
rg -n "AIza|YOUTUBE_API_KEY|oauth|cookie|password|secret|token" .
find . -type f \( -name "*.mp4" -o -name "*.mov" -o -name "*.m4v" -o -name "*.webm" \) -print
```

Also confirm:

- New or changed dependencies are expected and necessary.
- Build scripts and run scripts do not execute unrelated commands, installers, downloaded binaries, obfuscated shell, encoded payloads, or remote code.
- The app does not read shell history, browser profiles, SSH keys, keychains, password stores, documents, photos, or other personal files unrelated to WindowSeat.
- The app does not upload local files, environment variables, hostnames, usernames, process lists, or private paths.
- The app does not install launch agents, login items, browser extensions, background daemons, or privileged helpers without an explicit user request.
- `Config/current-source.json` and `Config/sources.json` are ignored local state.
- No concrete default YouTube video ID or private camera URL is committed as the default source.
- No API keys, OAuth credentials, cookies, local source lists, generated app bundles, downloaded videos, or private screenshots are staged or committed.
- YouTube playback uses official embed/player surfaces.
- The code does not download, cache, record, transcode, extract frames, or expose raw stream URLs from YouTube audiovisual content.
- `WKWebsiteDataStore.nonPersistent()` remains in use on macOS unless a documented privacy reason explains otherwise.

If any check is suspicious, stop and explain the exact file and line before running the app.

## macOS Install Flow

For the current macOS implementation:

1. Run `swift test`.
2. If `Config/current-source.json` is missing, create it by following `docs/AI_AGENT_CURATOR.md`.
3. Start with `scripts/run-current.sh`.
4. Check state with `scripts/status.sh`.
5. If changing scenery while WindowSeat is already running, update `Config/current-source.json` and let hot reload apply it.

Use `--debug-window` only for development UI checks. Normal operation should use the scripts.

## Windows And Linux

This repo does not currently ship Windows or Linux app code. For those platforms, read `docs/PORTING_CONCEPT.md` and build the smallest local display surface that preserves the same contract:

- local JSON runtime state
- official embedded player surfaces
- no copied YouTube media
- agent-managed source curation
- local run/status/stop controls

Do not invent a cross-platform implementation by weakening the media-safety or privacy rules.
