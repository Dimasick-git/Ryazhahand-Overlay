# Ryazhahand-Overlay

**EN:** Tesla overlay menu for Nintendo Switch (Atmosphere CFW). Forks Ultrahand-Overlay (ppkantorski) and replaces the underlying libtesla with libryazhahand. Adds Ryazha LED control, audio sound packs, PNG wallpaper, custom TXT reader. Requires `nx-ovlloader`. HOS 16.0.0+. License: GPL-2.0.

---

## Что это

Tesla-меню для Switch — гибкий интерпретатор `.ini`-пакетов и host для других оверлеев (RCU, статус-мониторов и т.д.). Форк [Ultrahand-Overlay](https://github.com/ppkantorski/Ultrahand-Overlay) с заменой libtesla на собственный форк [libryazhahand](https://github.com/Dimanchikgshehsbshene/libryazhahand).

## Что умеет

- Файловая работа на SD: создание, копирование, перемещение, удаление, .zip-распаковка без выхода в HBL.
- HTTPS-загрузка файлов прямо из меню.
- Правка `.ini` (ключи, значения, секции).
- Hex-патчи бинарей по смещению, конвертация IPS / pchtxt.
- Запуск других `.ovl` оверлеев (RCU, Status Monitor и т.д.).
- Ryazha-LED — управление подсветкой Joy-Con/Switch Lite (модули в `extra/sysmodules/ryazha-led/`, подробности в `docs/RYAZHA_LED.md`).
- Звуковые пакеты (WAV из ZIP'ов в `/config/ryazhahand/sounds/`).
- PNG-обои (`/config/ryazhahand/wallpaper.png`).
- TXT reader, конвертация модов.

## Установка

1. Atmosphere CFW.
2. `nx-ovlloader` (https://github.com/Dimanchikgshehsbshene/nx-ovlloader или совместимый).
3. Скачать релиз и распаковать `sdout.zip` в корень SD. В архиве:
   - `switch/.overlays/ovlmenu.ovl` — главный overlay.
   - `config/ryazhahand/` — конфиг + языки + дефолтные ассеты.
   - `atmosphere/` — sysmodule Ryazha-LED (если используется).
4. Запустить консоль. Открывать через Tesla hotkey (по умолчанию `L + ↓ + R-stick`).

## Использование

- Главное меню — список доступных overlay'ев и пакетов.
- Корневой пункт **Пакеты** — список папок из `/switch/.packages/<имя>/` с `package.ini`. Подробности формата — `docs/PACKAGES_RU.md`.
- Корневой пункт **Overlays** — другие `.ovl` файлы из `/switch/.overlays/`.
- Навигация и шорткаты — `docs/UI_RU.md`.

Минимальный package.ini:

```ini
[Привет, мир]
echo Hello, world!
```

## Документация

- `docs/UI_RU.md` — навигация, hotkeys, экраны.
- `docs/PACKAGES_RU.md` — формат `.ini` пакетов, команды.
- `docs/INTEGRATION_RU.md` — связи с другими проектами экосистемы Ryazha.
- `docs/RYAZHA_LED.md` — LED-модуль (Solid / Breathing / OnPress режимы).

## Сборка из исходников

```sh
git clone --recurse-submodules https://github.com/Dimanchikgshehsbshene/Ryazhahand-Overlay.git
cd Ryazhahand-Overlay
export DEVKITPRO=/opt/devkitpro
make
```

Результат — `out/ovlmenu.ovl`. CI workflow: `.github/workflows/release.yml` собирает `ovlmenu.ovl` + `lang.zip` + полный `sdout.zip` с ассетами (sounds, themes, payloads, nx-ovlloader бинарь).

## Ассеты по умолчанию

`scripts/bundle_upstream_assets.sh` тянет дефолтные звуки, темы, payloads из vendored upstream Ultrahand v2.4.2 (`vendor/ultrahand-upstream/`) и пакует в релизный `sdout.zip`. Локальные правки (PNG обои, LED конфиги) кладутся в `config/ryazhahand/` поверх дефолтов.

## Лицензия

GPL-2.0. Атрибуции — `common/README.md` (Studious-Pancake и др.).

Авторы: ppkantorski (Ultrahand), Dimasick-git (Ryazha-форк, LED-модуль, аудио, обои, TXT reader).
