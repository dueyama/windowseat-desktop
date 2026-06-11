#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CURRENT_SOURCE="${ROOT_DIR}/Config/current-source.json"
PATTERN='(WindowSeat|DesktopWindow)\.app/Contents/MacOS/DesktopWindow|/.build/.*/DesktopWindow'
PIDS="$(pgrep -f "${PATTERN}" 2>/dev/null || true)"

if [[ -z "${PIDS}" ]] && command -v osascript >/dev/null 2>&1; then
  PIDS="$(osascript -e 'tell application "System Events" to get unix id of processes whose name contains "DesktopWindow" or name contains "WindowSeat"' 2>/dev/null | tr ',' '\n' | awk '{$1=$1}; NF {print}' || true)"
fi

if [[ -z "${PIDS}" ]] && command -v swift >/dev/null 2>&1; then
  PIDS="$(swift -e 'import CoreGraphics; var pids = Set<Int>(); if let windows = CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID) as? [[String: Any]] { for window in windows { let name = window[kCGWindowOwnerName as String] as? String; if name == "DesktopWindow" || name == "WindowSeat", let pid = window[kCGWindowOwnerPID as String] as? Int { pids.insert(pid) } } }; for pid in pids.sorted() { print(pid) }' 2>/dev/null || true)"
fi

if [[ -n "${PIDS}" ]]; then
  echo "WindowSeat: running"
  while IFS= read -r pid; do
    [[ -n "${pid}" ]] && echo "PID: ${pid}"
  done <<< "${PIDS}"
else
  echo "WindowSeat: stopped"
fi

if [[ -f "${CURRENT_SOURCE}" ]]; then
  echo "Current source: ${CURRENT_SOURCE}"
  if command -v plutil >/dev/null 2>&1; then
    plutil -p "${CURRENT_SOURCE}" 2>/dev/null || true
  else
    cat "${CURRENT_SOURCE}"
  fi
else
  echo "Current source: missing"
fi
