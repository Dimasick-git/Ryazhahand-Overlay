#!/usr/bin/env bash
# build_lite_led.sh -- собирает liteswitch sysmodule + overlay из
# вендоренного исходника extra/sysmodules/liteswitch/ и раскладывает
# готовые бинари в SD-структуру дистрибутива.
#
# Использование:
#   bash scripts/build_lite_led.sh <DEST_DIR>
#
# DEST_DIR -- корень SD-стейджа (обычно out/), внутрь раскладываются:
#   atmosphere/contents/0100000000000FED/exefs.nsp
#   atmosphere/contents/0100000000000FED/flags/boot2.flag
#   atmosphere/contents/0100000000000FED/toolbox.json
#   switch/.overlays/liteswitch.ovl
#
# Переменные:
#   LED_SKIP_FETCH=1   -- общая переменная для всего LED-стека (см.
#                         fetch_led_sysmodule.sh). Если выставлена,
#                         скрипт молча выходит 0 -- удобно для
#                         оффлайн-сборки без devkitpro.
#
# Зависимости: devkitpro/devkita64 toolchain (DEVKITPRO=/opt/devkitpro).
# В CI-контейнере devkitpro/devkita64 всё уже есть.

set -euo pipefail

DEST="${1:-out}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LITE_SRC="$REPO_ROOT/extra/sysmodules/liteswitch"

if [ "${LED_SKIP_FETCH:-0}" = "1" ]; then
    echo "  ~ LED_SKIP_FETCH=1 -- liteswitch sysmodule в этот dist не включаем"
    exit 0
fi

if [ ! -d "$DEST" ]; then
    echo "[!] dest dir '$DEST' не существует" >&2
    exit 1
fi

if [ ! -d "$LITE_SRC" ]; then
    echo "[!] vendored liteswitch source '$LITE_SRC' не найден" >&2
    exit 0
fi

if [ -z "${DEVKITPRO:-}" ] || [ ! -d "${DEVKITPRO:-}" ]; then
    echo "  ~ DEVKITPRO не выставлен -- liteswitch не собираем, dist остаётся overlay-only"
    exit 0
fi

echo "  ~ Собираем liteswitch (Zach van Welzen, MIT)..."
# `make all` строит и sysmodule, и overlay; кладёт .nsp в out/atmosphere/...
# Изолируем сборку, чтобы не оставлять артефакты в git.
BUILD_TMP=$(mktemp -d)
trap 'rm -rf "$BUILD_TMP"' EXIT
cp -r "$LITE_SRC/." "$BUILD_TMP/"

if ! (cd "$BUILD_TMP" && make -s all 2>&1 | tail -20); then
    echo "[!] liteswitch make all упал -- пропускаем, overlay остаётся без Lite-sysmodule" >&2
    exit 0
fi

# Раскладка по out/
if [ -d "$BUILD_TMP/out/atmosphere" ]; then
    mkdir -p "$DEST/atmosphere"
    cp -r "$BUILD_TMP/out/atmosphere/." "$DEST/atmosphere/"
    echo "  + $DEST/atmosphere/contents/0100000000000FED/ -- liteswitch sysmodule"
fi

# Overlay управления (отдельный от Ryazha-LED -- работает с config
# /config/led-control/, см. README liteswitch). Если найден -- кладём.
LITE_OVL=$(find "$BUILD_TMP/overlay" -maxdepth 2 -name '*.ovl' 2>/dev/null | head -1 || true)
if [ -n "$LITE_OVL" ]; then
    mkdir -p "$DEST/switch/.overlays"
    cp "$LITE_OVL" "$DEST/switch/.overlays/liteswitch.ovl"
    echo "  + $DEST/switch/.overlays/liteswitch.ovl"
fi

echo "  ~ liteswitch собран. Лицензия MIT, автор Zach van Welzen."
