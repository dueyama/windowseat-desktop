# Repository Guidelines

## Project Goal

WindowSeat is a macOS AppKit prototype that makes the desktop feel like a live scenic window.
The safe default implementation embeds official players or public camera streams instead of copying media.

## Non-Negotiable Constraints

- Do not add code that downloads, stores, caches, transcodes, records, or extracts frames from YouTube audiovisual content.
- Use official YouTube embed/player surfaces for YouTube playback.
- Keep `WKWebsiteDataStore.nonPersistent()` unless there is a documented privacy reason to change it.
- Do not commit API keys, OAuth credentials, cookies, local source lists, generated app bundles, downloaded videos, or screenshots containing private data.
- Keep `Config/sources.json` local-only. Commit `Config/sources.example.json` for schema examples.
- Keep `Config/current-source.json` local-only. Commit `Config/current-source.example.json` for AI-agent handoff examples.
- Do not commit a concrete default YouTube URL or video ID. Public example files are schema references only; the first real source is generated locally by an AI agent.
- Treat GitHub publication as public-by-default. Remove personal paths, private camera URLs, and internal notes before pushing.

## Development Commands

Before installing, running, or porting WindowSeat for a user, read `docs/AGENT_INSTALL_SAFETY.md`.
If recommending or setting up recurring Codex automation, read `docs/CODEX_AUTOMATION.md` and ask for approval before creating or changing automations.

```sh
swift test
swift build
swift run DesktopWindow --source-file Config/current-source.json --debug-window
scripts/run-current.sh
scripts/status.sh
scripts/stop.sh
```

Use `--debug-window` while developing UI so the app appears as a normal window.
Without it, the app creates borderless windows near the desktop layer and ignores mouse events.

## Code Style

- Prefer small AppKit classes over broad abstractions.
- Keep policy-sensitive behavior in named helpers so it is easy to audit.
- Put pure parsing, validation, and HTML generation in `DesktopWindowCore`; keep AppKit/WebKit code in the executable target.
- Avoid dependencies until there is a concrete need.
- Add focused tests for validation, source parsing, and generated embed HTML.

## YouTube And Source Handling

- Before curating or changing scenic sources, read `docs/AI_AGENT_CURATOR.md` and follow its current source-selection guidance.
- For Windows or Linux users, read `docs/PORTING_CONCEPT.md` and treat the macOS app as a reference implementation rather than something that installs directly on those platforms.
- Keep evolving source-selection rules in `docs/AI_AGENT_CURATOR.md`; do not keep expanding README install/run prompts with ad hoc curation instructions.
- A YouTube video ID must be validated before embedding.
- Do not parse or shell out to tools that expose raw stream URLs for YouTube.
- If source search is added, use the YouTube Data API for discovery metadata only and keep keys out of git.
- If an AI agent selects the daily source, it may write metadata to `Config/current-source.json`; it must not write downloaded media or extracted stream URLs.
- AI agents are expected to manage runtime state through `scripts/run-current.sh`, `scripts/status.sh`, and `scripts/stop.sh`.
- Menu-facing Japanese source notes must include at least one concrete local fact or place-context cue, not only local time, selection rationale, or verification details.
- On first run, if `Config/current-source.json` is missing, the AI agent should search automatically instead of copying an example. Prefer a fixed scenic live camera in a region that is currently in daylight.
- If WindowSeat is already running, source changes should be applied by updating `Config/current-source.json` and letting the app hot-reload. Do not stop and restart the app just to change scenery.
- Default source selection should prefer fixed scenic cameras. Reject walking, driving, ride, drone, tour, or compilation videos unless the user explicitly asks for motion.
- Prefer sources whose maximum quality is clearly 4K/UHD when available, especially when the title or official metadata says `4K`.
- Prefer true currently-live streams. If no suitable fixed live source is available, a recording is acceptable, but set `sourceKind` to `recording` and clearly state that in `agentNote.body`.
- Reject `配信済み`, ended, streamed, streamed live, premiere, or archive videos whenever the user specifically asks for live.
- Prefer candidates that pass YouTube oEmbed or an equivalent embeddability check. If a candidate is not embeddable, choose another source instead of leaving a visible YouTube error on the desktop.
- Runtime playback failures must fail quietly on the desktop surface. Keep user-facing recovery controls in the menu bar, especially "Open in YouTube".
- Direct HLS/MJPEG support is acceptable only for sources that publish a public stream URL and permit this use.

## Before GitHub Publication

Run:

```sh
swift test
rg -n "AIza|YOUTUBE_API_KEY|oauth|cookie|password|secret|token" .
find . -type f \( -name "*.mp4" -o -name "*.mov" -o -name "*.m4v" -o -name "*.webm" \) -print
```

Review `docs/GITHUB_PUBLICATION.md` before creating the remote repository.
