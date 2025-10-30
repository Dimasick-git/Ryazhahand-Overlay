#!/usr/bin/env bash
set -euo pipefail

SD_ROOT=${1:-/e}
SD_DATA="$SD_ROOT/switch/RyazhenkaAI/data"

echo "Copying gbatemp_data to $SD_DATA"
mkdir -p "$SD_DATA"
cp -f gbatemp_data/*.txt "$SD_DATA" || true
echo "Done."
