#!/bin/bash
# Download MuseTalk inference weights for Linux.
# The weight set is identical to the Mac one (dwpose skipped — mediapipe is used
# instead; syncnet skipped — training only), so this delegates to that script.
set -euo pipefail

cd "$(dirname "$0")"
if [ -z "${VIRTUAL_ENV:-}" ] && [ -f .venv/bin/activate ]; then
  source .venv/bin/activate
fi

for bin in huggingface-cli gdown curl; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "❌ '$bin' not found — run ./setup_linux.sh first (or install curl)."
    exit 1
  fi
done

exec ./download_weights_mac.sh
