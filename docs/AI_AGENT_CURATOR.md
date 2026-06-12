# AI Agent Curator

WindowSeat is intended to be operated by Codex or any other AI agent that can browse the web, edit a local JSON file, and run local shell commands on the user's Mac.

The app does not need to own a YouTube Data API key. An external agent can search, judge, and write the selected source. WindowSeat only validates the selected YouTube video ID and renders it through the official embedded player.

The agent owns day-to-day operation: pick the source, write the metadata, start the app, stop the app, and refresh it when the source changes.

Public repository files must not include a concrete default video URL or video ID. The first real source is created locally by the AI agent in `Config/current-source.json`, which is ignored by git.

## First Run Contract

When `Config/current-source.json` does not exist, the agent should automatically curate the first source before starting WindowSeat:

1. Determine the user's current local time and UTC time.
2. Prefer a scenic fixed-view live camera whose location is currently in daylight, roughly 07:00-17:30 local camera time.
3. Search for calm live cameras in currently-daylight regions, such as beaches, harbors, mountains, city skylines, quiet rail windows, or observatories.
4. Verify that the candidate is currently live when possible, not labeled ended, streamed, archive, premiere, or 配信済み.
5. Prefer sources whose title, channel description, or visible metadata indicates 4K/UHD maximum quality. Do not treat a low-resolution source as equivalent just because the player is asked for high quality.
6. Prefer candidates that pass YouTube oEmbed or an equivalent embeddability check.
7. Write `Config/current-source.json`.
8. If WindowSeat is already running, wait for hot reload. If it is not running, run `scripts/run-current.sh`.

If the user asks for a specific region and it is currently night there, prefer the user's instruction. Otherwise, the default first-run choice should be somewhere in daylight.

## Daily Contract

The agent writes one file:

```txt
Config/current-source.json
```

The file should match:

```json
{
  "title": "Short human-readable title",
  "youtubeVideoID": "YOUTUBE_VIDEO_ID",
  "fillMode": "fill",
  "muted": true,
  "showOverlay": false,
  "sourceKind": "live",
  "preferredQuality": "highres",
  "selectedBy": "Codex",
  "selectedAt": "2026-06-11T12:00:00+09:00",
  "agentNote": {
    "headline": "今日は静かな窓から始めましょう",
    "body": "仕事の雰囲気に合う短い一言。"
  },
  "quote": {
    "text": "短いオリジナルの一言、または権利上問題のない短い引用。",
    "attribution": "Optional attribution"
  }
}
```

`quote.attribution` is optional. Prefer original text unless the quote is clearly safe to reuse.

## Agent Selection Rules

- Prefer live scenic cameras, nature views, city skylines, harbors, mountains, beaches, rail windows, or quiet streets.
- For first run and ordinary automatic refreshes, prefer cameras whose location is currently in daylight.
- Prefer sources whose maximum quality is clearly 4K/UHD when available, especially if the title or official description says `4K`.
- Prefer fixed or nearly fixed camera viewpoints by default. Background sources should feel like a window, not a moving tour.
- Prefer true currently-live streams, but a recording is acceptable when no suitable fixed live source is available.
- If a recording is selected, set `sourceKind` to `recording` and clearly say in `agentNote.body` that it is a recording.
- Reject sources labeled as ended, streamed, streamed live, premiere, archive, or 配信済み when the user specifically asks for live.
- Prefer videos that pass YouTube oEmbed or an equivalent embeddability check. Reject candidates that clearly show owner-disabled embedding.
- Avoid news loops, disaster streams, strongly political channels, heavy advertising overlays, private/security cameras, and people-centered streams.
- Avoid walking videos, driving videos, ride videos, drone footage, virtual tours, highlight reels, and panning compilation streams unless the user explicitly asks for motion.
- Prefer official tourism boards, observatories, transport operators, resorts, municipalities, and established webcam channels.
- Keep the selected output to metadata: video ID, title, agent note, quote, and timestamp.
- Keep `muted` set to `true` unless the user explicitly asks for sound.
- Keep `showOverlay` set to `false` by default so the note stays in the menu bar and does not cover the desktop.
- Do not download, store, cache, record, transcode, or extract frames from YouTube content.
- If the agent is unsure whether a video is live, embeddable, or appropriate, keep the previous source or ask before changing it.
- If playback still fails at runtime, the app should keep the desktop quiet; use the menu bar "Open in YouTube" action for recovery.

## Scenic Source Workflow

Treat the first plausible result as a candidate, not the final choice. Build a short list, reject weak fits early, then write `Config/current-source.json` only after one source is clearly better for a quiet desktop window.

Before selecting:

1. Read `AGENTS.md`, `README.md`, and this guide.
2. Inspect `Config/current-source.json` when present so the new source is meaningfully fresh.
3. Inspect local bookmarks in `Config/sources.json` when present.
4. Prefer a video ID that is not already bookmarked. If a bookmarked source is reused because it is still the strongest available live/daylight/fixed choice, say so in `agentNote.body`.
5. Check whether WindowSeat is already running with `scripts/status.sh` before changing runtime state.

Candidate quality:

- Prefer fixed or very slow scenic cameras over motion content. The view should feel like a window, not a tour.
- Favor daylight at the camera location for automatic rotations unless the user asks for a specific region or nighttime mood.
- Prefer true live streams. Avoid premieres, ended streams, archives, looped recordings, and videos labeled `配信済み`, `streamed`, `streamed live`, `premiere`, or `archive` when a live source is requested.
- Prefer official or stable public operators: tourism boards, observatories, transport operators, resorts, municipalities, and established webcam channels.
- Prefer 4K/UHD sources when the title or official metadata clearly says so, but do not trust resolution claims alone.
- Avoid heavy on-screen UI, news tickers, disaster footage, security-camera framing, people-centered scenes, loud brand overlays, fast pans, walking/driving/riding videos, drone footage, virtual tours, highlight reels, and compilation streams.

Verification:

- Validate the YouTube video ID before embedding.
- Use YouTube oEmbed or an equivalent metadata-only embeddability check before selecting a source.
- When practical, also check the official embed URL returns successfully.
- If source search is implemented in code, use the YouTube Data API for discovery metadata only and keep keys out of git.
- Do not use downloaders, raw stream URL extractors, frame extraction, screenshots, recording, caching, transcoding, or any path that copies YouTube audiovisual content.
- If embeddability, live state, or suitability remains unclear, keep the previous source or ask the user instead of switching to a questionable candidate.

## Menu Copy And Metadata

Menu-facing text should be concise Japanese and should include the country name when the city, island, region, or camera name may not be obvious to the user.

Use:

- `title`: include country and recognizable place, plus the source title when useful.
- `agentNote.headline`: short Japanese headline with country/place.
- `agentNote.body`: explain why this source was chosen, including daylight/live/4K/embeddability checks and any fallback or bookmarked-source reuse.
- `quote.text`: short original Japanese line that suits calm desk work; prefer original text over copyrighted quotations.

Keep:

- `sourceKind`: `live` for true live sources; `recording` only when a recording fallback is intentionally chosen.
- `muted`: `true` unless the user explicitly asks for sound.
- `showOverlay`: `false` unless the user explicitly wants desktop text.
- `preferredQuality`: `highres`.
- `fillMode`: `fill`.

## Applying A Source

Only write the ignored local runtime file:

```txt
Config/current-source.json
```

Do not commit or push `Config/current-source.json` or `Config/sources.json`.

If WindowSeat is already running, update `Config/current-source.json` and let hot reload pick it up. Do not stop and restart just to change scenery. Verify with `scripts/status.sh` and, when available, the diagnostics log for `hot reloaded source=<videoId>`.

If WindowSeat is stopped and the task is to run or apply the current window, start it with `scripts/run-current.sh`. If the task is only to prepare the next source, updating the ignored runtime config is enough.

## Run With The Current Source

```sh
scripts/run-current.sh
scripts/status.sh
scripts/stop.sh
```

`Config/current-source.json` is ignored by git so local agent choices do not leak into the public repository. Do not copy the example file as a default source; it is only a schema reference.

## Suggested Agent Prompt

```txt
Find one scenic YouTube live camera suitable for a calm work desktop today.
Prefer a fixed camera located somewhere currently in daylight.
Prefer a source whose maximum quality is clearly 4K/UHD.
Use official or stable public channels when possible.
Do not download media or extract stream URLs.
Return only metadata for WindowSeat's Config/current-source.json:
title, youtubeVideoID, fillMode, muted, showOverlay, sourceKind, selectedBy, selectedAt,
preferredQuality, agentNote.headline, agentNote.body, quote.text, and optional quote.attribution.
Keep the note in Japanese, brief, calm, and work-appropriate.
After writing the file, let the running app hot-reload. If it is not running, run scripts/run-current.sh.
```
