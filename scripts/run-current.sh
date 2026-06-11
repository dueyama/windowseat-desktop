#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CURRENT_SOURCE="${ROOT_DIR}/Config/current-source.json"

if [[ ! -f "${CURRENT_SOURCE}" ]]; then
  cat <<EOF
Config/current-source.json is missing.

AI agent first-run task:
1. Read ${ROOT_DIR}/docs/AI_AGENT_CURATOR.md.
2. Find one calm fixed-view YouTube live camera in a region that is currently in daylight.
3. Prefer true live, embeddable sources. Avoid ended, streamed, archive, premiere, moving tour, driving, drone, and compilation videos.
4. Write ${CURRENT_SOURCE}.
5. Run scripts/run-current.sh again.

Current local time: $(date '+%Y-%m-%d %H:%M:%S %Z')
Current UTC time:   $(date -u '+%Y-%m-%d %H:%M:%S UTC')
EOF
  exit 2
fi

exec "${ROOT_DIR}/scripts/run-background.sh" "${CURRENT_SOURCE}"
