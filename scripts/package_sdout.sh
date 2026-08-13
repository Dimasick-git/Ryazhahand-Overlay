#!/usr/bin/env bash
#
# Собирает единственный SD-card-ready архив из out/.
# Этот скрипт вызывается и build.yml, и release.yml, чтобы CI-артефакт
# совпадал с файлом, который пользователи получают из GitHub Release.

set -euo pipefail

out_dir=${1:-out}
archive=${2:-sdout.zip}
repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

if [ ! -d "$out_dir" ]; then
    echo "[package] ERROR: output directory does not exist: $out_dir" >&2
    exit 1
fi

# Упаковка без этих компонентов создаёт внешне успешный, но неполный release.
for asset in \
    switch/.overlays/ovlmenu.ovl \
    atmosphere/contents/0100000000000ED1/exefs.nsp \
    atmosphere/contents/420000000007E51A/exefs.nsp \
    atmosphere/contents/420000000007E51B/exefs.nsp \
    switch/Ryazhahand-Reload/Ryazhahand-Reload.nro \
    config/ryazhahand/sounds/default.zip \
    config/ryazhahand/.loaded_sounds/tick.wav \
    config/ryazhahand/payloads/ryzhand_updater.bin; do
    if [ ! -s "$out_dir/$asset" ]; then
        echo "[package] ERROR: required SD bundle asset is missing: $asset" >&2
        exit 1
    fi
done

# При чистой установке интерфейс должен стартовать по-русски, а меню выбора
# обязано видеть все поставляемые локали и темы. Проверяем именно полный набор
# исходных пользовательских файлов, а не один контрольный пример.
test -f "$out_dir/config/ryazhahand/config.ini" || {
    echo "[package] ERROR: default config.ini is missing" >&2
    exit 1
}
grep -Eq '^default_lang=ru$' "$out_dir/config/ryazhahand/config.ini" || {
    echo "[package] ERROR: default language must be ru" >&2
    exit 1
}

for language in "$repo_root"/lang/*.json; do
    [ -f "$language" ] || continue
    bundled="$out_dir/config/ryazhahand/lang/$(basename "$language")"
    test -s "$bundled" || {
        echo "[package] ERROR: bundled language is missing: $(basename "$language")" >&2
        exit 1
    }
done

for theme in "$repo_root"/config/ryazhahand/themes/*.ini; do
    [ -f "$theme" ] || continue
    bundled="$out_dir/config/ryazhahand/themes/$(basename "$theme")"
    test -s "$bundled" || {
        echo "[package] ERROR: bundled theme is missing: $(basename "$theme")" >&2
        exit 1
    }
done

archive_dir=$(dirname "$archive")
archive_name=$(basename "$archive")
mkdir -p "$archive_dir"
archive_dir=$(cd "$archive_dir" && pwd)
archive_path="$archive_dir/$archive_name"
rm -f "$archive_path"

# Содержимое out/ попадает прямо в корень ZIP, готовый для распаковки в корень SD.
(
    cd "$out_dir"
    zip -q -r "$archive_path" .
)

test -s "$archive_path" || {
    echo "[package] ERROR: archive was not created: $archive_path" >&2
    exit 1
}

echo "[package] created $archive_path"
