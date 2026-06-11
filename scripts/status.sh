#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CURRENT_SOURCE="${ROOT_DIR}/Config/current-source.json"
PID_FILE="/tmp/windowseat-desktop.pid"
PATTERN='(WindowSeat|DesktopWindow)\.app/Contents/MacOS/DesktopWindow|/.build/.*/DesktopWindow'
PIDS=""
APPLE_PIDS=""

if command -v osascript >/dev/null 2>&1; then
  APPLE_PIDS="$(osascript -e 'tell application "System Events" to get unix id of processes whose name is "DesktopWindow" or name is "WindowSeat"' 2>/dev/null | tr ',' '\n' | awk '{$1=$1}; NF {print}' || true)"
  APPLE_PIDS+=$'\n'
  APPLE_PIDS+="$(osascript -e 'tell application "System Events" to get unix id of processes whose name contains "DesktopWindow" or name contains "WindowSeat"' 2>/dev/null | tr ',' '\n' | awk '{$1=$1}; NF {print}' || true)"
fi

if [[ -f "${PID_FILE}" ]]; then
  read -r pid_from_file < "${PID_FILE}" || true
  if [[ "${pid_from_file:-}" =~ ^[0-9]+$ ]]; then
    kill_check="$(kill -0 "${pid_from_file}" 2>&1 || true)"
    command_check="$(ps -p "${pid_from_file}" -o command= 2>/dev/null || true)"
    if [[ "${kill_check}" == *"operation not permitted"* || "${kill_check}" == *"Operation not permitted"* || "${command_check}" == *"DesktopWindow"* ]] || printf '%s\n' "${APPLE_PIDS}" | awk -v pid="${pid_from_file}" '$0 == pid { found = 1 } END { exit !found }'; then
      PIDS+="${pid_from_file}"$'\n'
    fi
  fi
fi

PIDS+="$(pgrep -f "${PATTERN}" 2>/dev/null || true)"$'\n'
PIDS+="$(
  ps -o pid=,command= -ax 2>/dev/null \
    | awk '/(WindowSeat|DesktopWindow)\.app\/Contents\/MacOS\/DesktopWindow|\/\.build\/.*\/DesktopWindow/ {print $1}' \
    || true
)"$'\n'

PIDS+="${APPLE_PIDS}"$'\n'

if command -v swift >/dev/null 2>&1; then
  PIDS+="$(swift -e 'import CoreGraphics; var pids = Set<Int>(); if let windows = CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID) as? [[String: Any]] { for window in windows { let name = window[kCGWindowOwnerName as String] as? String; if name == "DesktopWindow" || name == "WindowSeat", let pid = window[kCGWindowOwnerPID as String] as? Int { pids.insert(pid) } } }; for pid in pids.sorted() { print(pid) }' 2>/dev/null || true)"$'\n'
fi

PIDS="$(printf '%s\n' "${PIDS}" | awk 'NF && !seen[$0]++')"

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
