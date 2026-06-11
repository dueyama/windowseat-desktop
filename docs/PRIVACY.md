# Privacy Notes

WindowSeat is designed as a local display surface operated by an AI agent.

## Local Files

- `Config/current-source.json` is local-only and ignored by git.
- `Config/sources.json` and `Config/*.local.json` are local-only and ignored by git.
- Example files under `Config/*.example.json` are schema references only and should not contain real default source IDs.

## YouTube Playback

- YouTube content is loaded through the official embedded player.
- The app uses a non-persistent `WKWebView` website data store.
- The app does not download, store, cache, record, transcode, or extract frames from YouTube audiovisual content.
- The app does not extract raw stream URLs.

## API Keys And Accounts

- WindowSeat does not include a YouTube Data API key.
- Source discovery is expected to be performed by Codex or another local AI agent outside the app.
- API keys, OAuth credentials, cookies, and account-specific data must stay in local ignored files or environment variables.

## Agent Boundary

The AI agent may search the web, choose a source, and write `Config/current-source.json`.
WindowSeat only reads that local file and renders the selected source.
