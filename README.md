# WindowSeat

WindowSeat is an AI-curated scenic desktop window.
Codex or another local AI agent finds a high-quality scenic live camera, chooses a quiet view for your current mood and time of day, writes the local configuration, and keeps your Mac desktop feeling like a window seat somewhere beautiful.

WindowSeat は、Codex と協働して動作する「世界の絶景デスクトップ窓」アプリです。
Codex などのローカルAIエージェントが、その時刻や気分に合う高画質の風景ライブカメラを探し、ローカル設定を書き換え、Macのデスクトップを世界のどこかの窓側席にします。

This repository currently contains the macOS implementation. The core idea is not macOS-only: an AI agent can use the same pattern on Windows or Linux by building the right local display surface for that operating system, then curating and updating the source in the same way.

このリポジトリは現時点ではmacOS向け実装です。ただしコンセプト自体はmacOS専用ではありません。AIエージェントに依頼すれば、WindowsやLinuxでも、そのOSに合うローカル表示面を作り、同じように景色の選定・更新を任せる形で実現できます。

Repository: <https://github.com/dueyama/windowseat-desktop>

## Start With Codex / Codexで起動

GitHubでこのリポジトリを見つけたら、Mac上のCodexに次のように頼むだけで始められる想定です。
公開READMEには具体的なデフォルト動画URLや動画IDは置きません。

```txt
https://github.com/dueyama/windowseat-desktop のREADMEを読んで、WindowSeatを実行してください。
初回起動で Config/current-source.json がなければ、起動した時刻に昼間の地域を優先して、落ち着いた固定視点のYouTubeライブカメラを1つ探し、Config/current-source.json を作ってから起動してください。
景色を変えるときは、最大画質が4K/UHDと分かるソースを優先し、起動中ならアプリを再起動せず Config/current-source.json の更新で反映してください。
起動後はCodexで管理してください。
景色、国や地域、ライブ優先か録画でもよいか、音の有無、今日の一言は、私の指示に合わせてカスタムしてください。
YouTubeの映像をダウンロードしたり、ストリームURLを抽出したりしないでください。
```

If you found this repository on GitHub, give the repository URL to Codex running on your Mac and ask it to read the README and run the app:

```txt
Read the README for https://github.com/dueyama/windowseat-desktop and run WindowSeat.
On first launch, if Config/current-source.json does not exist, choose one calm fixed-view YouTube live camera in a region that is currently in daylight, write Config/current-source.json, and then start the app.
When changing scenery, prefer sources whose maximum quality is clearly 4K/UHD, and if the app is already running, update Config/current-source.json so it hot-reloads without restarting.
After it starts, manage it with Codex.
Customize the scenery, country or region, live-vs-recording preference, sound, and daily note based on my instructions.
Do not download YouTube media or extract stream URLs.
```

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

## Use With Codex / Codexで使う

If you found this repository on GitHub, the intended path is to give the repository URL to Codex running on your Mac and ask it to manage the app for you.

GitHubでこのリポジトリを見つけた場合は、Mac上で動くCodexにリポジトリURLを渡し、このアプリの実行と管理を任せるのが想定される使い方です。

Example prompt:

```txt
Clone https://github.com/dueyama/windowseat-desktop and manage WindowSeat for me.
Run `swift test`. If `Config/current-source.json` does not exist,
find a calm fixed-view YouTube live camera in a region that is currently in daylight,
prefer a source whose maximum quality is clearly 4K/UHD,
write `Config/current-source.json`, then start the app with `scripts/run-current.sh`.
Do not download YouTube media or extract stream URLs.
```

日本語の依頼例:

```txt
https://github.com/dueyama/windowseat-desktop をcloneして、WindowSeatの実行と管理をしてください。
`swift test` を実行してください。`Config/current-source.json` がなければ、
起動した時刻に昼間の地域を優先して、落ち着いた固定視点のYouTubeライブカメラを1つ探し、
最大画質が4K/UHDと分かるソースを優先し、
`Config/current-source.json` を作ってから `scripts/run-current.sh` で起動してください。
YouTubeの映像をダウンロードしたり、ストリームURLを抽出したりしないでください。
```

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

## Scheduled Curation / 定期的な景色変更

If your Codex environment supports automations or scheduled tasks, you can ask Codex to refresh WindowSeat on a schedule. The app itself does not need a built-in scheduler: Codex chooses a new source, updates `Config/current-source.json`, and the running app hot-reloads it.

Codex のオートメーションや定期実行が使える環境では、WindowSeat の景色を定期的に変更できます。アプリ本体にスケジューラを持たせるのではなく、Codex が新しい景色を選び、`Config/current-source.json` を更新し、起動中のアプリがホットリロードで反映します。

Example automation prompt:

```txt
Every weekday morning, choose a calm fixed-view scenic YouTube live camera
in a region that is currently in daylight. Prefer sources whose maximum quality
is clearly 4K/UHD. Update Config/current-source.json for WindowSeat.
If WindowSeat is not running, start it with scripts/run-current.sh.
Do not download media or extract stream URLs.
```

日本語の定期実行依頼例:

```txt
平日の朝に、WindowSeat用の落ち着いた固定視点のYouTubeライブカメラを1つ選んでください。
起動時刻に昼間の地域を優先し、最大画質が4K/UHDと分かるソースを優先してください。
Config/current-source.json を更新してください。
WindowSeatが起動していなければ scripts/run-current.sh で起動してください。
YouTubeの映像をダウンロードしたり、ストリームURLを抽出したりしないでください。
```

To use the AI-curated daily window workflow, ask the agent to create or update `Config/current-source.json` first:

AIが毎日選ぶ「今日の窓」として使う場合は、先に `Config/current-source.json` を作成または更新させます。

```txt
Find one scenic YouTube live camera suitable for calm desk work today.
Prefer a fixed-view camera in a region that is currently in daylight.
Prefer a source whose maximum quality is clearly 4K/UHD.
Follow `docs/AI_AGENT_CURATOR.md`.
Write `Config/current-source.json`. If WindowSeat is already running, let it hot-reload.
If it is not running, run `scripts/run-current.sh`.
```

```txt
今日の仕事に合う、落ち着いた絶景のYouTubeライブカメラを1つ探してください。
起動した時刻に昼間の地域を優先し、固定視点のカメラを選んでください。
最大画質が4K/UHDと分かるソースを優先してください。
`docs/AI_AGENT_CURATOR.md` に従って `Config/current-source.json` を作り、
WindowSeatが起動中ならホットリロードで反映してください。起動していなければ `scripts/run-current.sh` を実行してください。
```

This must run on a Mac that can display macOS GUI windows. A cloud-only coding environment can edit the repository, but it cannot put a live window on your desktop.

これはmacOSのGUIウィンドウを表示できるMac上で動かす必要があります。クラウドだけの開発環境ではリポジトリの編集はできますが、あなたのデスクトップにライブ窓を表示することはできません。

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
