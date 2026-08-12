#!/usr/bin/env bash
# build_ryazha_led.sh -- собирает единый Ryazha-LED sysmodule из
# extra/sysmodules/ryazha-led/ и раскладывает .nsp + flags в
# SD-структуру дистрибутива.
#
# Title ID: 0100000000000ED1
#
# Раньше в релиз попадало два отдельных бинаря:
#   atmosphere/contents/0100000000000895/   -- sys-notif-LED (Xc987, MIT)
#   atmosphere/contents/0100000000000FED/   -- liteswitch (Z. van Welzen, MIT)
# Они независимо работали с разными конфиг-файлами и UI'ями оверлеев.
#
# Теперь оба слиты в один sysmodule (extra/sysmodules/ryazha-led/),
# который сам auto-detect'ит железо через setsysGetProductModel:
#   Lite                  -> GPIO PWM (логика из liteswitch)
#   Erista/Mariko/OLED    -> hidsys notification LED (логика из sys-notif-LED)
# Единый конфиг /config/ryazhahand/led.ini -- его пишет
# source/ryazha_led/ нашего оверлея.
#
# Использование:
#   bash scripts/build_ryazha_led.sh <DEST_DIR>
#
# Переменные:
#   LED_SKIP_FETCH=1 -- skip сборки (нет devkitpro / нет интернета).
#   DEVKITPRO=/opt/devkitpro -- путь к toolchain (есть в CI-контейнере).

set -euo pipefail

DEST="${1:-out}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$REPO_ROOT/extra/sysmodules/ryazha-led"

if [ "${LED_SKIP_FETCH:-0}" = "1" ]; then
    echo "  ~ LED_SKIP_FETCH=1 -- Ryazha-LED sysmodule в этот dist не включаем"
    exit 0
fi

if [ ! -d "$DEST" ]; then
    echo "[!] dest dir '$DEST' не существует" >&2
    exit 1
fi

if [ ! -d "$SRC" ]; then
    echo "[!] vendored Ryazha-LED source '$SRC' не найден" >&2
    exit 1
fi

if [ -z "${DEVKITPRO:-}" ] || [ ! -d "${DEVKITPRO:-}" ]; then
    echo "  ~ DEVKITPRO не выставлен -- Ryazha-LED не собираем, dist остаётся overlay-only"
    exit 0
fi

echo "  ~ Собираем Ryazha-LED sysmodule..."
BUILD_TMP=$(mktemp -d)
trap 'rm -rf "$BUILD_TMP"' EXIT
cp -r "$SRC/." "$BUILD_TMP/"

if ! (cd "$BUILD_TMP" && make -s 2>&1 | tail -20); then
    echo "[!] Ryazha-LED sysmodule сборка упала" >&2
    exit 1
fi

# Раскладка по out/. TARGET в Makefile = $(notdir $(CURDIR)) = ryazha-led,
# поэтому elf2nso положит ryazha-led.nsp рядом с Makefile.
TID="0100000000000ED1"
NSP="$BUILD_TMP/ryazha-led.nsp"

if [ ! -f "$NSP" ]; then
    echo "[!] $NSP не появился после сборки" >&2
    exit 1
fi

mkdir -p "$DEST/atmosphere/contents/$TID/flags"
cp "$NSP"                              "$DEST/atmosphere/contents/$TID/exefs.nsp"
cp "$BUILD_TMP/toolbox.json"           "$DEST/atmosphere/contents/$TID/toolbox.json"
touch                                  "$DEST/atmosphere/contents/$TID/flags/boot2.flag"

echo "  + $DEST/atmosphere/contents/$TID/exefs.nsp"
echo "  ~ Ryazha-LED собран (title id $TID). Лицензия MIT."
echo "    Основано на liteswitch (Z. van Welzen) и sys-notif-LED (Xc987)."
