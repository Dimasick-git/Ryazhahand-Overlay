#!/usr/bin/env bash
#
# Copy upstream Ryzhand-Overlay assets + nx-ovlloader release into our out/
# so that release zip = sd-card-ready (как у ppkantorski sdout.zip).
#
# Что копируется (из vendor/ryazhahand-upstream/, submodule пинят на v2.4.5):
#   sounds/default.zip (из репы)     -> config/ryazhahand/sounds/default.zip (пак для UI выбора)
#                                       + распаковка в config/ryazhahand/.loaded_sounds/ (активный пак)
#   themes/*.ini                     -> config/ryazhahand/themes/
#   payloads/ryazhahand_updater.bin   -> config/ryazhahand/payloads/
#   common/audio_mastervolume/*.ips  -> atmosphere/exefs_patches/audio_mastervolume/
#
# НЕ копируем upstream-овский wallpapers/atmosphere.rgba -- наша система
# использует PNG (wallpaper.png), libpng декодирует на лету.
# Юзер должен класть свои *.png в /config/ryazhahand/wallpapers/.
#
# Что качается из github releases (online-only step):
#   nx-ovlloader.zip (latest)       -> atmosphere/contents/420000000007E51A/ + E51B/
#                                       + switch/Ryazhahand-Reload/Ryazhahand-Reload.nro
#
# UPSTREAM_SKIP_FETCH=1 пропускает online step (для offline CI / локальной
# проверки сборки). UPSTREAM_SKIP_ASSETS=1 пропускает всё (для быстрого
# debug-make без 4 МБ копий).

# -u is intentionally omitted: the script probes optional env toggles
# (UPSTREAM_SKIP_FETCH / UPSTREAM_SKIP_ASSETS) that are normally unset.
set -eo pipefail

OUT="${1:-out}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UPSTREAM="$ROOT/vendor/ryazhahand-upstream"

if [ "${UPSTREAM_SKIP_ASSETS:-0}" = "1" ]; then
    echo "[bundle] UPSTREAM_SKIP_ASSETS=1 -- skipping all bundle steps"
    exit 0
fi

if [ ! -d "$UPSTREAM/wallpapers" ]; then
    echo "[bundle] WARN: vendor/ryazhahand-upstream/ не инициализирован."
    echo "[bundle]       Запусти: git submodule update --init --recursive"
    echo "[bundle]       Пропускаю bundle-фазу (out/ останется минимальной)."
    exit 0
fi

mkdir -p "$OUT/config/ryazhahand/wallpapers"
mkdir -p "$OUT/config/ryazhahand/sounds"
mkdir -p "$OUT/config/ryazhahand/.loaded_sounds"
mkdir -p "$OUT/config/ryazhahand/themes"
mkdir -p "$OUT/config/ryazhahand/payloads"
mkdir -p "$OUT/atmosphere/exefs_patches/audio_mastervolume"

# Wallpaper: НЕ копируем upstream'овскую atmosphere.rgba.
# У нас система PNG (libpng декодирует /config/ryazhahand/wallpaper.png
# в RGBA4444 для tesla-рендера на лету). Юзер кладёт свои *.png в
# /config/ryazhahand/wallpapers/ и выбирает через UI.

# Default sound pack -- единственный источник дефолтных звуков (лежит в репе,
# не тянем из upstream). В релиз кладём:
#   sounds/default.zip     -- сам пак, виден в UI выбора звуков как "default";
#   .loaded_sounds/*.wav   -- распакованный активный пак, Audio читает отсюда,
#                             чтобы дефолтный профиль звучал сразу из коробки.
# Россыпи WAV в sounds/ и папки .sounds/ больше нет.
DEFAULT_ZIP="$ROOT/config/ryazhahand/sounds/default.zip"
if [ -f "$DEFAULT_ZIP" ]; then
    cp "$DEFAULT_ZIP" "$OUT/config/ryazhahand/sounds/default.zip"
    if command -v unzip >/dev/null; then
        unzip -oq "$DEFAULT_ZIP" -d "$OUT/config/ryazhahand/.loaded_sounds"
        echo "[bundle] + sounds/default.zip (+ распаковка в .loaded_sounds/)"
    else
        echo "[bundle] WARN: unzip недоступен -- .loaded_sounds/ не заполнен"
    fi
else
    echo "[bundle] WARN: $DEFAULT_ZIP отсутствует -- дефолтный звук не упакован"
fi

# Themes -- наши Ryazha-темы из config/ryazhahand/themes/ (заменяют
# upstream'овские ultra-*.ini, их в релиз НЕ кладём).
THEMES_SRC="$ROOT/config/ryazhahand/themes"
if [ -d "$THEMES_SRC" ]; then
    for f in "$THEMES_SRC"/*.ini; do
        [ -f "$f" ] || continue
        cp "$f" "$OUT/config/ryazhahand/themes/$(basename "$f")"
    done
    echo "[bundle] + themes/*.ini (Ryazha: $(ls "$THEMES_SRC"/*.ini 2>/dev/null | wc -l))"
else
    echo "[bundle] WARN: $THEMES_SRC отсутствует -- темы не упакованы"
fi

# Дефолтные конфиги для свежей установки (config.ini c current_theme=Amber,
# дефолтная theme.ini, списки overlays/packages). RELEASE.ini сюда НЕ кладём --
# версию берёт корневой RELEASE.ini проекта.
CFG_SRC="$ROOT/config/ryazhahand"
for name in config.ini theme.ini overlays.ini packages.ini; do
    [ -f "$CFG_SRC/$name" ] || continue
    cp "$CFG_SRC/$name" "$OUT/config/ryazhahand/$name"
done
echo "[bundle] + default config (config/theme/overlays/packages).ini"

# Собственный updater payload. Храним его в репозитории под именем Ryzhand,
# чтобы bundle и runtime URL не зависели от legacy-названия upstream-артефакта.
UPDATER_PAYLOAD="$ROOT/payloads/ryzhand_updater.bin"
if [ -f "$UPDATER_PAYLOAD" ]; then
    cp "$UPDATER_PAYLOAD" "$OUT/config/ryazhahand/payloads/ryzhand_updater.bin"
    echo "[bundle] + payloads/ryzhand_updater.bin"
else
    echo "[bundle] ERROR: $UPDATER_PAYLOAD отсутствует" >&2
    exit 1
fi

# IPS patches для master volume (4 файла, по одному на каждую версию HOS).
for f in "$UPSTREAM/common/audio_mastervolume"/*.ips; do
    [ -f "$f" ] || continue
    cp "$f" "$OUT/atmosphere/exefs_patches/audio_mastervolume/$(basename "$f")"
done
echo "[bundle] + audio_mastervolume IPS-патчи: $(ls "$UPSTREAM/common/audio_mastervolume"/*.ips 2>/dev/null | wc -l)"

# nx-ovlloader -- собирается из нашего submodule vendor/nx-ovlloader/
# (форк ppkantorski/nx-ovlloader с auto-sync). Раньше качали release
# zip из ppkantorski/nx-ovlloader/releases/latest напрямую -- теперь
# контролируем версию через submodule pin.
NXOVL="$ROOT/vendor/nx-ovlloader"
if [ "${UPSTREAM_SKIP_FETCH:-0}" = "1" ]; then
    echo "[bundle] UPSTREAM_SKIP_FETCH=1 -- nx-ovlloader не собирается"
elif [ -d "$NXOVL/source" ]; then
    echo "[bundle] building nx-ovlloader from vendor/nx-ovlloader..."
    # Инициализируем nested submodule в оригинальном worktree ДО копирования:
    # gitlink внутри временной копии не содержит корректного пути к modules/.
    if [ ! -f "$NXOVL/external/nx-ovlreloader/Makefile" ]; then
        echo "[bundle]   external/nx-ovlreloader пуст -- инициализирую"
        git -C "$NXOVL" submodule update --init --recursive
    fi
    if [ ! -f "$NXOVL/external/nx-ovlreloader/Makefile" ]; then
        echo "[bundle] ERROR: nested nx-ovlreloader не инициализирован"
        exit 1
    fi

    NXOVL_BUILD="$(mktemp -d)"
    # Копируем submodule в temp, чтобы make не пачкал исходный worktree.
    cp -r "$NXOVL/." "$NXOVL_BUILD/"
    if ! (cd "$NXOVL_BUILD" && make > build.log 2>&1); then
        echo "[bundle] ERROR: nx-ovlloader build failed"
        tail -n 80 "$NXOVL_BUILD/build.log" || true
        rm -rf "$NXOVL_BUILD"
        exit 1
    fi
    tail -n 5 "$NXOVL_BUILD/build.log"

    # Успешный make обязан создать полный набор загрузчика и reloader-а.
    # Не подменяем частичную сборку сообщением об успехе: release workflow
    # опирается на эти компоненты в sdout.zip.
    for asset in \
        atmosphere/contents/420000000007E51A/exefs.nsp \
        atmosphere/contents/420000000007E51B/exefs.nsp \
        switch/Ryazhahand-Reload/Ryazhahand-Reload.nro; do
        if [ ! -s "$NXOVL_BUILD/out/$asset" ]; then
            echo "[bundle] ERROR: missing nx-ovlloader artifact: $asset"
            rm -rf "$NXOVL_BUILD"
            exit 1
        fi
    done

    cp -r "$NXOVL_BUILD/out/atmosphere"/. "$OUT/atmosphere/"
    mkdir -p "$OUT/switch"
    cp -r "$NXOVL_BUILD/out/switch"/. "$OUT/switch/"
    rm -rf "$NXOVL_BUILD"
    echo "[bundle] + nx-ovlloader (built from submodule)"
else
    # Fallback: submodule не инициализирован -- качаем upstream release zip.
    # Происходит когда юзер клонировал без --recursive.
    echo "[bundle] vendor/nx-ovlloader пуст -- fallback на upstream release"
    NXOVL_TMP="$(mktemp -d)"
    NXOVL_URL="https://github.com/Dimasick-git/nx-ovlloader/releases/latest/download/nx-ovlloader.zip"
    NXOVL_FALLBACK="https://github.com/ppkantorski/nx-ovlloader/releases/latest/download/nx-ovlloader.zip"
    if command -v curl >/dev/null && (curl -sSL --fail "$NXOVL_URL" -o "$NXOVL_TMP/nxovl.zip" || curl -sSL --fail "$NXOVL_FALLBACK" -o "$NXOVL_TMP/nxovl.zip"); then
        (cd "$NXOVL_TMP" && unzip -q nxovl.zip)
        if [ -d "$NXOVL_TMP/atmosphere/contents" ]; then
            mkdir -p "$OUT/atmosphere/contents"
            cp -r "$NXOVL_TMP/atmosphere/contents"/420000000007E51A "$OUT/atmosphere/contents/" 2>/dev/null || true
            cp -r "$NXOVL_TMP/atmosphere/contents"/420000000007E51B "$OUT/atmosphere/contents/" 2>/dev/null || true
        fi
        if [ -d "$NXOVL_TMP/switch" ]; then
            mkdir -p "$OUT/switch"
            cp -r "$NXOVL_TMP/switch"/. "$OUT/switch/"
        fi
        echo "[bundle] + nx-ovlloader (via release zip fallback)"
    else
        echo "[bundle] WARN: не удалось скачать nx-ovlloader fallback."
    fi
    rm -rf "$NXOVL_TMP"
fi

echo "[bundle] done -> $OUT"
