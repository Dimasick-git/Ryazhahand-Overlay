# Ryazhahand-Overlay

**EN:** Standalone Tesla overlay menu for Nintendo Switch (Atmosphere CFW), powered by its own [libryazhahand](https://github.com/Dimasick-git/libryazhahand) library. Ships Ryazha LED control, audio sound packs, PNG wallpaper, custom TXT reader. Requires `nx-ovlloader`. HOS 16.0.0+. License: GPL-2.0.

---

## Что это

Самостоятельное Tesla-меню для Switch — гибкий интерпретатор `.ini`-пакетов и host для других оверлеев (RCU, статус-мониторов и т.д.). Работает на собственной библиотеке [libryazhahand](https://github.com/Dimasick-git/libryazhahand).

## Что умеет

Движок пакетов:

- Файловая работа на SD: создание, копирование, перемещение, удаление, .zip-распаковка без выхода в HBL.
- HTTPS-загрузка файлов прямо из меню; авто-NTP-синхронизация часов перед загрузками.
- Правка `.ini` (ключи, значения, секции), `ini_file_source` с wildcard-путями и накоплением.
- Hex-патчи бинарей по смещению, конвертация IPS / pchtxt.
- Запуск других `.ovl` оверлеев (RCU, Status Monitor и т.д.) + уведомление, если файл оверлея отсутствует.
- Управление сисмодулями из пакетов: `module` (start/stop по program ID), `ipc-exec`, `ntp-sync`, `refresh-return`, `refresh combos`.
- Условные плейсхолдеры `{if_null}` / `{if_==}` / `{if_>}` / `{if_version_>=}` и др., `{crc32(<путь>)}`, `{ovl_version(<путь>)}` (+ совместимый alias для сторонних пакетов).
- Standalone-условия в пакетах: `path_exists`, `ipc_exists`, `module_exists`, `module_is_active`, `matching_txt_line`, `matching_hex_val`, `matching_ini_val` (все с `!`-отрицанием).
- Директивы меню: `;visibility_condition=`, `;toggle_state_condition=`, `;hold=true` (удержание A с прогрессом), `;device_state=`, `;hos_version=`, `;ams_version=`, `;ram_size_gb=`.

Настройки и UI:

- Ввод: навигация левым стиком (вкл/выкл), настраиваемое время удержания A (0.5–5 с).
- Уведомления: вкл/выкл по категориям (инфо/успехи/предупреждения/ошибки), длительность показа, максимум слотов, тихий режим, hotkey-переключатель API-уведомлений.
- Сканер обновлений оверлеев (ручной запуск «Проверить обновления», чтобы не блокировать загрузки).
- Темы + выбор цвета текста (color picker), динамический логотип, эффекты переходов.

Ryazha-кастомы:

- Ryazha-LED — управление подсветкой Joy-Con/Switch Lite: режимы Откл/Постоянно/Пульсация/Плавный/При нажатии + яркость (модули в `extra/sysmodules/ryazha-led/`, подробности в `docs/RYAZHA_LED.md`).
- Звуковые пакеты (WAV из ZIP'ов в `/config/ryazhahand/sounds/`) + раздельные тумблеры звука: навигация/подтверждение/отмена/стена.
- PNG-обои (`/config/ryazhahand/wallpaper.png`, libpng) + цветовой фильтр (Normal/Red/Green/Blue/Sepia/Invert).
- TXT-читалка (UTF-8 word-wrap, смена шрифта, из `/switch/RyazhenkaAI/data/`), конвертация модов.
- Локализация: 14 языков, дефолт — русский.

> Текущая линия релизов — 2.3.x.

## Установка

1. Atmosphere CFW.
2. `nx-ovlloader` (https://github.com/Dimasick-git/nx-ovlloader или совместимый).
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
git clone --recurse-submodules https://github.com/Dimasick-git/Ryazhahand-Overlay.git
cd Ryazhahand-Overlay
export DEVKITPRO=/opt/devkitpro
make
```

Результат — `out/ovlmenu.ovl`. CI workflow: `.github/workflows/release.yml` собирает `ovlmenu.ovl` + `lang.zip` + полный `sdout.zip` с ассетами (sounds, themes, payloads, nx-ovlloader бинарь).

## Ассеты по умолчанию

`scripts/bundle_upstream_assets.sh` тянет дефолтные звуки, темы и payloads из vendored-сабмодуля в `vendor/` и пакует в релизный `sdout.zip`. Локальные правки (PNG обои, LED конфиги) кладутся в `config/ryazhahand/` поверх дефолтов. Сабмодули обновляются автоматически каждые 6 часов (workflow `sync_submodules.yml` с проверочной сборкой перед пушем).

## Лицензия

GPL-2.0. Атрибуции — `common/README.md` (Studious-Pancake и др.).

Авторы: Dimasick-git (Ryazhahand, LED-модуль, аудио, обои, TXT reader). В основе — открытый код ppkantorski и контрибьюторов (атрибуции — `common/README.md`, `SUB_LICENSE`).
