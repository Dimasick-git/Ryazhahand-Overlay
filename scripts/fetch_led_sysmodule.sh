#!/usr/bin/env bash
# fetch_led_sysmodule.sh -- скачивает прибилт sysmodule sys-notif-LED
# (Xc987/sys-notif-LED, MIT) и распаковывает в SD-структуру дистрибутива
# Ryazhahand-Overlay. Sysmodule пишет настройки LED HOME-кнопки из
# /config/ryazhahand/led.ini, поэтому Ryazha-LED модуль оверлея и
# фоновый прошитый sysmodule работают как одна пара.
#
# Использование:
#   bash scripts/fetch_led_sysmodule.sh <DEST_DIR>
#
# DEST_DIR -- корень SD-стейджа (обычно out/), внутрь раскладываются:
#   atmosphere/contents/0100000000000895/exefs.nsp
#   atmosphere/contents/0100000000000895/flags/boot2.flag
#   atmosphere/contents/0100000000000895/toolbox.json
#   switch/.overlays/sys-notif-LED.ovl
#
# Переменные:
#   LED_SYSMODULE_TAG  -- какая версия Xc987/sys-notif-LED (default: 1.0.1)
#   LED_SKIP_FETCH=1   -- пропустить скачивание (например, для локальной
#                         оффлайн-сборки). Тогда скрипт молча выходит 0.

set -euo pipefail

DEST="${1:-out}"
TAG="${LED_SYSMODULE_TAG:-1.0.1}"

if [ "${LED_SKIP_FETCH:-0}" = "1" ]; then
    echo "  ~ LED_SKIP_FETCH=1 -- LED sysmodule в этот dist не включаем"
    exit 0
fi

if [ ! -d "$DEST" ]; then
    echo "[!] dest dir '$DEST' не существует" >&2
    exit 1
fi

URL="https://github.com/Xc987/sys-notif-LED/releases/download/${TAG}/sys-notif-LED.zip"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

echo "  ~ Качаем Xc987/sys-notif-LED@${TAG}..."
if ! curl -sSfL "$URL" -o "$TMP/sysmodule.zip"; then
    echo "[!] не удалось скачать $URL -- LED sysmodule в dist не попадёт" >&2
    # Не валим сборку: pacman/связь могут быть недоступны, overlay сам по
    # себе остаётся валидным релизом, LED просто не запустится.
    exit 0
fi

unzip -q -o "$TMP/sysmodule.zip" -d "$TMP/extracted"

# Сам sysmodule (титл-id 0100000000000895)
if [ -d "$TMP/extracted/atmosphere" ]; then
    mkdir -p "$DEST/atmosphere"
    cp -r "$TMP/extracted/atmosphere/." "$DEST/atmosphere/"
    echo "  + $DEST/atmosphere/contents/0100000000000895/ -- prebuilt sysmodule"
fi

# Upstream-овский control overlay (sys-notif-LED.ovl) НЕ копируем --
# управление вынесено внутрь нашего Ryazhahand (секция "Свечение LED"),
# отдельный .ovl в /switch/.overlays/ только засоряет меню.

echo "  ~ sys-notif-LED@${TAG} установлен. Лицензия MIT, автор Xc987."
