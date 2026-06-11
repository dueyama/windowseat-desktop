#!/usr/bin/env bash
set -euo pipefail

VIDEO_ID="${1:-${DESKTOP_WINDOW_VIDEO_ID:-}}"

if [[ -z "${VIDEO_ID}" ]]; then
  echo "Usage: scripts/run-dev.sh YOUTUBE_VIDEO_ID"
  echo "Or set DESKTOP_WINDOW_VIDEO_ID."
  exit 64
fi

swift run DesktopWindow --video-id "${VIDEO_ID}" --debug-window
