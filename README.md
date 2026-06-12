# WindowSeat

WindowSeat is an AI-curated scenic desktop window.
Codex or another local AI agent finds a high-quality scenic live camera, chooses a quiet view for your current mood and time of day, writes the local configuration, and keeps your Mac desktop feeling like a window seat somewhere beautiful.

WindowSeat は、Codex と協働して動作する「世界の絶景デスクトップ窓」アプリです。
Codex などのローカルAIエージェントが、その時刻や気分に合う高画質の風景ライブカメラを探し、ローカル設定を書き換え、Macのデスクトップを世界のどこかの窓側席にします。

This repository currently contains the macOS implementation. The core idea is not macOS-only: an AI agent can use the same pattern on Windows or Linux by building the right local display surface for that operating system, then curating and updating the source in the same way.

このリポジトリは現時点ではmacOS向け実装です。ただしコンセプト自体はmacOS専用ではありません。AIエージェントに依頼すれば、WindowsやLinuxでも、そのOSに合うローカル表示面を作り、同じように景色の選定・更新を任せる形で実現できます。

Repository: <https://github.com/dueyama/windowseat-desktop>

## Install With An Agent / エージェントでインストール

The intended handoff is short. Give the repository to a local agent and ask it to inspect, install, and run WindowSeat:

```txt
https://github.com/dueyama/windowseat-desktop の README を読んで、コードの安全性を確認してからインストールして。
```

```txt
Read the README for https://github.com/dueyama/windowseat-desktop, check the code safety, then install it.
```

The detailed agent instructions live outside the install prompt:

- `docs/AGENT_INSTALL_SAFETY.md`: code inspection checklist for forks or unfamiliar checkouts
- `docs/AI_AGENT_CURATOR.md`: scenic source selection and local runtime config
- `docs/CODEX_AUTOMATION.md`: optional Codex automation recommendation after install
- `docs/PORTING_CONCEPT.md`: how a Windows or Linux agent should port the concept
- `docs/YOUTUBE_POLICY.md`: media-safety boundaries

公開READMEには具体的なデフォルト動画URLや動画IDを置きません。インストール依頼文も長くしません。Codex や Claude などのローカルエージェントが、このREADMEと `docs/` の指針を読んで、フォークや未知のcheckoutに不審なコードが混ざっていないか確認し、初回ソース選定、起動まで行う想定です。

WindowSeat is a macOS prototype for turning the desktop into a quiet scenic window.
It renders a YouTube live camera through the official embedded player in a borderless AppKit window placed near the desktop layer.

The first implementation deliberately avoids downloading, frame extraction, or media caching. YouTube content is embedded, not copied.

WindowSeat is designed to be operated by an AI agent. Codex or another local agent can find a scenic YouTube live camera, write a small JSON file with today's view and note, start or stop the app, and keep the desktop window fresh.

WindowSeat は、AIエージェントに運用させる前提のアプリです。Codex などのローカルAIエージェントが「今日の絶景ライブカメラ」を探し、短い一言つきのJSONを書き、起動・停止・更新まで管理します。アプリ本体は、その結果をデスクトップの窓として表示するランタイムです。

## Current macOS Status

- Swift Package Manager project
- AppKit menu-bar style executable
- Per-screen desktop-level windows
- `WKWebView` with non-persistent website data
- YouTube IFrame Player API rendering
- Basic source configuration through CLI arguments or JSON
- AI-agent curated source metadata with a short daily note
- Menu bar access to the current AI note and quote
- Menu bar controls for mute/unmute and opening the current source in YouTube
- Menu bar bookmarks backed by local-only `Config/sources.json`
- Hot reloads `Config/current-source.json` while the app is running
- Muted-by-default playback, with `muted: false` available per source
- Desktop overlay is off by default; set `showOverlay: true` per source to show it on screen
- Core unit tests

This is not yet a polished signed `.app` bundle.

The current SwiftPM executable target is still named `DesktopWindow`. The repo and product concept are named WindowSeat; the scripts hide most of that implementation detail.

現時点の SwiftPM 実行ターゲット名はまだ `DesktopWindow` です。リポジトリ名とプロダクトコンセプトは WindowSeat で、通常は `scripts/` 経由で起動するため、この内部名を意識する必要はあまりありません。

## Agent Operation / エージェント運用

The agent-facing control surface is intentionally small:

AIエージェント向けの操作面は、意図的に小さくしています。

```sh
scripts/run-current.sh   # start the current curated window
scripts/status.sh        # inspect current state
scripts/stop.sh          # stop WindowSeat
```

```sh
scripts/run-current.sh   # 現在の「今日の窓」を起動
scripts/status.sh        # 状態を確認
scripts/stop.sh          # WindowSeatを停止
```

For daily or scheduled curation, the agent updates only `Config/current-source.json` and follows `docs/AI_AGENT_CURATOR.md`. If WindowSeat is already running, the app hot-reloads that local file.

定期的な景色変更でも、READMEに長い依頼文を追加する必要はありません。エージェントは `docs/AI_AGENT_CURATOR.md` に従い、ローカル専用の `Config/current-source.json` を更新します。

If the agent supports recurring automations, it should recommend one after a successful install or first launch. See `docs/CODEX_AUTOMATION.md`.

Codex がオートメーションを使える場合は、インストールまたは初回起動後に「設定しますか？」と提案するのが自然です。詳細は `docs/CODEX_AUTOMATION.md` にあります。

This must run on a Mac that can display macOS GUI windows. A cloud-only coding environment can edit the repository, but it cannot put a live window on your desktop.

これはmacOSのGUIウィンドウを表示できるMac上で動かす必要があります。クラウドだけの開発環境ではリポジトリの編集はできますが、あなたのデスクトップにライブ窓を表示することはできません。

Windows or Linux agents should read `docs/PORTING_CONCEPT.md` and build the local display surface for that OS instead of trying to run the AppKit implementation directly.

Windows/Linux の場合は、同じ Swift/AppKit 実装をそのまま入れるのではなく、`docs/PORTING_CONCEPT.md` を読んで、そのOS向けの表示面を作る想定です。

## Run

Use a YouTube video ID directly:

```sh
swift run DesktopWindow --video-id YOUR_VIDEO_ID --debug-window
```

Use an AI-agent curated single source:

```sh
swift run DesktopWindow --source-file Config/current-source.json --debug-window
```

`Config/*.example.json` files are schema examples for publication. They are not default scenery sources and should be replaced by an AI agent before launch.

`Config/*.example.json` は公開用のスキーマ例です。デフォルトの景色ソースではないので、起動前にAIエージェントが `Config/current-source.json` を作ります。

Drop `--debug-window` when you want the window to be placed at the desktop layer:

```sh
swift run DesktopWindow --video-id YOUR_VIDEO_ID
```

For launch debugging:

```sh
swift run DesktopWindow --source-file Config/current-source.json --diagnostics-log /tmp/DesktopWindow.log
```

For the most realistic local test, build and launch a development `.app` bundle:

```sh
scripts/run-background.sh Config/current-source.json
```

For normal AI-agent operation:

```sh
scripts/run-current.sh
```

AIエージェントに通常運用させる場合:

```sh
scripts/run-current.sh
```

This runs until you quit from the menu bar item or stop the terminal command.
It does not replace the macOS wallpaper image. It creates a borderless window just above the desktop layer, behind normal app windows, and ignores mouse events.

You can also set:

```sh
export DESKTOP_WINDOW_VIDEO_ID=YOUR_VIDEO_ID
swift run DesktopWindow
```

## Test

```sh
swift test
```

## Design Constraints

- Use the official YouTube embedded player path.
- Keep sources muted by default. Only set `muted: false` when the user explicitly wants sound.
- Keep `showOverlay` false by default so notes do not collide with the Dock or desktop icons.
- Prefer fixed scenic cameras by default. Avoid walking, driving, ride, drone, tour, or compilation videos unless the user explicitly asks for motion.
- Prefer true currently-live streams. If no suitable fixed live source is available, a recording is acceptable, but mark `sourceKind: "recording"` and say so in the note.
- Prefer sources whose maximum quality is clearly 4K/UHD when available. The app asks YouTube for high quality, but source selection should still prefer cameras that publish 4K.
- Prefer embeddable sources. If YouTube playback is rejected at runtime, the desktop surface fails quietly instead of showing a large error message.
- Do not download, cache, store, transcode, or extract frames from YouTube audiovisual content.
- Keep API keys in environment variables or local ignored files only.
- Commit example source metadata, not personal watch lists or private URLs.
- Expect YouTube quality selection to be adaptive. The app can prefer high-quality live streams, but cannot guarantee 4K playback in every environment.

## Roadmap

- Source search UI backed by YouTube Data API
- AI-agent daily curation workflow
- Rotation schedules by time of day
- Native settings window
- Signed `.app` packaging
- Direct HLS/MJPEG source support for cameras that explicitly provide public stream URLs

## Publication

Before publishing to GitHub, follow `docs/GITHUB_PUBLICATION.md`.
Privacy boundaries are documented in `docs/PRIVACY.md`.

## License

MIT License. See `LICENSE`.

## AI Agent Curation

See `docs/AI_AGENT_CURATOR.md`.

AIエージェントによる日替わり選定については `docs/AI_AGENT_CURATOR.md` を参照してください。
