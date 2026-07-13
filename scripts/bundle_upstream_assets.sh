#!/usr/bin/env bash
#
# Copy upstream Ultrahand-Overlay assets + nx-ovlloader release into our out/
# so that release zip = sd-card-ready (как у ppkantorski sdout.zip).
#
# Что копируется (из vendor/ultrahand-upstream/, submodule пинят на v2.4.5):
#   sounds/default.zip (из репы)     -> config/ryazhahand/sounds/default.zip (пак для UI выбора)
#                                       + распаковка в config/ryazhahand/.loaded_sounds/ (активный пак)
#   themes/*.ini                     -> config/ryazhahand/themes/
#   payloads/ultrahand_updater.bin   -> config/ryazhahand/payloads/
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
UPSTREAM="$ROOT/vendor/ultrahand-upstream"

if [ "${UPSTREAM_SKIP_ASSETS:-0}" = "1" ]; then
    echo "[bundle] UPSTREAM_SKIP_ASSETS=1 -- skipping all bundle steps"
    exit 0
fi

if [ ! -d "$UPSTREAM/wallpapers" ]; then
    echo "[bundle] WARN: vendor/ultrahand-upstream/ не инициализирован."
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

# Updater payload.
if [ -f "$UPSTREAM/payloads/ultrahand_updater.bin" ]; then
    cp "$UPSTREAM/payloads/ultrahand_updater.bin" \
       "$OUT/config/ryazhahand/payloads/ultrahand_updater.bin"
    echo "[bundle] + payloads/ultrahand_updater.bin"
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
    NXOVL_BUILD="$(mktemp -d)"
    # Копируем submodule в temp чтобы make не пачкал submodule worktree
    # (внутри submodule .git -- gitlink файл, его трогать не нужно).
    cp -r "$NXOVL/." "$NXOVL_BUILD/"
    # nx-ovlreloader как nested submodule. Если submodule не клонирован
    # рекурсивно -- скачиваем как fallback.
    if [ ! -f "$NXOVL_BUILD/external/nx-ovlreloader/Makefile" ]; then
        echo "[bundle]   external/nx-ovlreloader пуст -- инициализирую"
        (cd "$NXOVL_BUILD" && git submodule update --init --recursive 2>/dev/null) || true
    fi
    if [ -f "$NXOVL_BUILD/Makefile" ]; then
        (cd "$NXOVL_BUILD" && make 2>&1 | tail -5) || echo "[bundle] WARN nx-ovlloader build failed"
        # nx-ovlloader make кладёт артефакты в out/atmosphere/... формате,
        # либо в корень. Проверим оба.
        if [ -d "$NXOVL_BUILD/out/atmosphere" ]; then
            cp -r "$NXOVL_BUILD/out/atmosphere"/. "$OUT/atmosphere/"
        fi
        if [ -d "$NXOVL_BUILD/out/switch" ]; then
            mkdir -p "$OUT/switch"
            cp -r "$NXOVL_BUILD/out/switch"/. "$OUT/switch/"
        fi
        echo "[bundle] + nx-ovlloader (built from submodule)"
    else
        echo "[bundle] WARN: vendor/nx-ovlloader Makefile отсутствует"
    fi
    rm -rf "$NXOVL_BUILD"
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
