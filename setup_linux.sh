#!/bin/bash
# One-shot environment setup for Linux (NVIDIA GPU or CPU).
# Usage: ./setup_linux.sh [cuda-tag]    cuda-tag: cu121 (default), cu118, cu124, cpu
set -euo pipefail

cd "$(dirname "$0")"
CUDA_TAG="${1:-cu121}"
PYTHON="${PYTHON:-python3.11}"

for bin in "$PYTHON" ffmpeg; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "❌ '$bin' not found. On Ubuntu/Debian:"
    echo "   sudo apt install python3.11 python3.11-venv ffmpeg libgl1 libglib2.0-0"
    exit 1
  fi
done

if [ ! -d .venv ]; then
  "$PYTHON" -m venv .venv
fi
source .venv/bin/activate
pip install --upgrade pip

# Torch first, from the index matching the CUDA driver (or CPU-only wheels).
pip install "torch>=2.3.0" "torchvision>=0.18.0" "torchaudio>=2.3.0" \
  --index-url "https://download.pytorch.org/whl/${CUDA_TAG}"
pip install -r requirements-linux.txt

# server.py mounts this (gitignored) dir at /media; it must exist at startup.
mkdir -p upstream/data/demo_five

python - <<'EOF'
import torch
if torch.cuda.is_available():
    print(f"✅ CUDA available: {torch.cuda.get_device_name(0)}")
else:
    print("⚠️  CUDA not available — inference will run on CPU (slow).")
EOF

echo "Next: ./download_weights_linux.sh"
