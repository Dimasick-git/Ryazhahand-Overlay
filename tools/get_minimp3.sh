#!/usr/bin/env bash
set -euo pipefail

DST_DIR="lib/libRYAZHAHAND/common"
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
mkdir -p "$DST_DIR"

fetch() {
	local url="$1" out="$2"
	echo "Downloading $url -> $out"
	curl -L --fail --retry 3 "$url" -o "$out"
}

fetch "https://raw.githubusercontent.com/lieff/minimp3/master/minimp3_ex.h" "$DST_DIR/minimp3_ex.h"
fetch "https://raw.githubusercontent.com/lieff/minimp3/master/minimp3.h" "$DST_DIR/minimp3.h"

echo "minimp3 headers installed at $DST_DIR"
