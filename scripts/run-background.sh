#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE_FILE="${1:-"${ROOT_DIR}/Config/current-source.json"}"
APP_DIR="${ROOT_DIR}/build/WindowSeat.app"

if [[ "${SOURCE_FILE}" != /* ]]; then
  SOURCE_FILE="${ROOT_DIR}/${SOURCE_FILE}"
fi

if [[ ! -f "${SOURCE_FILE}" ]]; then
  echo "Source file not found: ${SOURCE_FILE}" >&2
  echo "Ask an AI agent to create Config/current-source.json first. See docs/AI_AGENT_CURATOR.md." >&2
  exit 2
fi

"${ROOT_DIR}/scripts/stop.sh"
"${ROOT_DIR}/scripts/build-dev-app.sh" "${APP_DIR}"
exec "${APP_DIR}/Contents/MacOS/DesktopWindow" --source-file "${SOURCE_FILE}"
