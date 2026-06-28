# Codex Automation

WindowSeat works best when Codex refreshes the scenic source on a schedule.

Do not create an automation silently. After a successful install or first launch, recommend it and ask for approval.

Suggested recommendation:

```txt
WindowSeat は Codex のオートメーションで定期的に景色を入れ替えられます。
平日の朝などに自動で新しいライブ景色を探す設定を作りますか？
```

Suggested English recommendation:

```txt
WindowSeat can use a Codex automation to refresh the scenic source on a schedule.
Do you want me to set one up?
```

## When To Recommend It

Recommend a Codex automation when:

- WindowSeat has installed or launched successfully.
- `Config/current-source.json` exists or can be created by following `docs/AI_AGENT_CURATOR.md`.
- The user appears to want WindowSeat managed over time, not just tested once.
- The Codex environment supports automations or recurring tasks.

Do not recommend it when:

- The user only asked for code inspection.
- The app has not been installed or launched yet.
- The user has asked not to change local runtime state.
- The current environment cannot keep a local desktop app running or cannot update local files later.

## User Approval

The agent should ask before creating or changing any recurring automation.

Good default:

```txt
平日の朝に、WindowSeat の景色を自動更新するオートメーションを設定しますか？
```

Other reasonable schedules:

- every weekday morning
- every morning
- morning and late afternoon
- only on demand, with no automation

If the user approves, create the automation in Codex rather than adding a scheduler to the WindowSeat app.

## Automation Task Contract

The recurring task should:

1. Read `AGENTS.md`, `README.md`, and `docs/AI_AGENT_CURATOR.md`.
2. Inspect `Config/current-source.json` if present.
3. Inspect local bookmarks in `Config/sources.json` if present.
4. Prefer a fresh non-bookmarked source when practical.
5. Choose a calm fixed-view scenic source in a currently daylight location.
6. Prefer true live streams and 4K/UHD sources when available.
7. Verify embeddability with YouTube oEmbed or an equivalent metadata-only check.
8. Update only the ignored local runtime config `Config/current-source.json`.
9. Keep `muted: true`, `showOverlay: false`, `preferredQuality: "highres"`, and `fillMode: "fill"`.
10. Make `agentNote.body` include at least one concrete local fact or place-context cue, not only local time, selection rationale, or verification details.
11. If WindowSeat is already running, rely on hot reload and verify with `scripts/status.sh` and diagnostics logs when available.
12. If WindowSeat is stopped and the user expects it to be active, start it with `scripts/run-current.sh`.
13. Do not commit or push local runtime config.
14. Finish with a concise Japanese summary of the selected source and whether it reloaded or launched.

The automation belongs to Codex. The WindowSeat app should not grow its own scheduler just to support this workflow.
