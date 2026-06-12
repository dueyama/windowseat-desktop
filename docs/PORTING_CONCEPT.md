# Porting Concept

WindowSeat is a pattern, not only a macOS binary.

The current repository contains the macOS reference implementation: an AppKit desktop-level window, a WebKit player surface, local JSON runtime state, and agent-operated source curation. A Windows or Linux user should not expect this Swift/AppKit app to install directly on their machine. Instead, a local agent such as Codex or Claude can read the repo and build the equivalent local display surface for that operating system.

## Portable Contract

A port should preserve the same contract:

- Render a scenic source as a quiet desktop window or desktop-adjacent surface.
- Use official YouTube embed/player surfaces for YouTube playback.
- Do not download, cache, record, transcode, or extract frames or stream URLs from YouTube audiovisual content.
- Keep real source choices in local ignored runtime files, not in public repo defaults.
- Use a small local config equivalent to `Config/current-source.json`.
- Keep source bookmarks local, equivalent to `Config/sources.json`.
- Support agent-friendly run, status, and stop commands.
- Prefer hot reload or an equivalent config refresh over restarting just to change scenery.
- Keep playback muted by default, keep desktop text overlays off by default, and request high quality through the official player when available.
- Follow `docs/AI_AGENT_CURATOR.md` for scenic source selection.

## Platform Surface

The platform-specific code only needs to provide the display surface and runtime controls.

Possible Windows shape:

- A small app using WebView2 or another official embedded browser surface.
- A borderless, click-through or desktop-adjacent window when practical.
- A tray icon or small control surface for mute, reload, open source, and quit.
- PowerShell or shell commands for run, status, and stop.

Possible Linux shape:

- A GTK, Qt, Electron, WebKitGTK, or browser-based surface.
- X11 and Wayland behavior may differ; choose the most reliable desktop-adjacent window behavior for the target environment.
- A tray/status control where the desktop environment supports it.
- Shell commands for run, status, and stop.

The exact implementation can vary by OS. The important part is the local-agent workflow and the media-safety boundary, not AppKit itself.

## What This Repo Should Contain

The public repo should keep:

- The macOS reference implementation.
- The JSON schema examples.
- The curation and safety docs.
- Enough conceptual guidance for another local agent to create a Windows or Linux port.

The public repo should not need to contain:

- Windows or Linux implementations before someone asks for them.
- Concrete default YouTube video IDs or private camera URLs.
- API keys, credentials, cookies, generated app bundles, downloaded media, or screenshots containing private data.

## Agent Handoff

When a Windows or Linux user asks an agent to use this repo, the agent should:

1. Read `README.md`, `AGENTS.md`, this document, and `docs/AI_AGENT_CURATOR.md`.
2. Treat the macOS code as a reference implementation.
3. Build the smallest native or webview-based display surface that satisfies the portable contract.
4. Reuse the local JSON shape and source-selection rules.
5. Start with local-only runtime state and avoid committing concrete source choices.

日本語メモ: この repo は今のところ macOS 実装を持つリファレンスです。Windows/Linux では同じ Swift/AppKit アプリを無理に動かすのではなく、各OSのエージェントがこの文書と curator guide を読んで、同じ「ローカルJSON + 公式プレイヤー + デスクトップ窓 + エージェント選定」の形を作る想定です。
