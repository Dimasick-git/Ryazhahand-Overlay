# Changelog

Все заметные изменения Ryazhahand-Overlay. Формат заголовков `## [vX.Y.Z]`
используется workflow'ом релиза (`.github/workflows/release.yml`) для
автоизвлечения заметок к релизу.

## [v2.5.1] — 2026-10-04

### Добавлено
- Краткие описания на обзорных страницах настроек (управление, язык, системные
  инструменты, оформление) — на всех 14 языках. Скрипт
  `scripts/fill_translations.py` заполняет такие строки сразу во всех переводах.
- `payloads/ryzhand_updater.bin` входит в SD-бандл — обновление запускается из оверлея.

### Исправлено
- **Сборка с новым libnx:** `NacpStruct` переехал на `lang_data`, из-за чего чтение
  названий и версий оверлеев перестало компилироваться.
- Запуск дефолтного звукового пака.
- Загрузчики больше не меняют рабочий каталог глобально.

### Изменено
- **Ryazha-LED:** восстановлены автономные hidsys-паттерны, стабилизировано
  управление затуханием, убраны лишние HID-обновления; сборка падает, если
  sysmodule не собрался.
- **Миграция на Ryzhand завершена:** vendor-сабмодуль переименован в
  `ryazhahand-upstream`, ребрендинг доведён до конца.
- **SD-бандл и релизные ассеты объединены:** в релиз идёт только `sdout.zip`, его
  полнота проверяется (`scripts/package_sdout.sh`), сборка nx-ovlloader обязательна.
- **Комбинации клавиш:** конфиг консолидирован, детект Switch Lite повторяется при
  неудаче.
- **libryazhahand** обновлён до `9a75b98`: подвижные полноэкранные виджеты,
  компактные описания в списках, восстановление настройки npad после перезапуска
  HID, терпимость к отсутствию loader-info вне nx-ovlloader, акцентная кромка и
  глиф батареи в рамке оверлея.
- **Сборка:** make-jobserver передаётся во вложенные скрипты, параллельность
  ограничена верхним уровнем.

### Убрано
- Неиспользуемые хелперы оверлея, LED pulse API, мёртвый код обновления и устаревшие
  комментарии навигации.

### Релизный конвейер
- Ужесточена проверка release-workflow и защита от параллельных запусков обновления
  HB App Store.

---

**EN:** Compact descriptions on the settings overview pages in all 14 languages (plus
a script that fills such strings across every translation); updater payload shipped in
the SD bundle; build fixed for the new libnx (`NacpStruct` moved to `lang_data`);
Ryazha-LED autonomous hidsys patterns restored with steadier fade control; Ryzhand
rebrand completed (vendor submodule renamed); SD bundle and release assets unified
around a verified `sdout.zip`; key-combo config consolidated with retried Switch Lite
detection; libryazhahand bumped to `9a75b98`; dead code removed.

---

## [v2.4.0] — 2026-07-24

### Добавлено
- Поддержка контроллеров в стиле **GameCube** (NpadGc) в конфигурации пада оверлея.

### Изменено
- **Звуки:** единый дефолтный пак `default.zip`, убран дублирующийся пункт выбора и
  служебная папка `.sounds` — звук работает из коробки, меню чище.
- **libryazhahand:** синхронизация с upstream libryazhahand (856ddbd) с
  camelCase-правилом переименований (исправляет #12 библиотеки); отключён фоновый
  PSC-поллер сна — меньше лишних сервисных вызовов, совместимость с RCU-стеком.
- **vendor/ryazhahand-upstream** обновлён до v2.5.3.

### Релизный конвейер
- Релиз теперь запускается бампом `RELEASE.ini` + записью в changelog (тег создаётся
  автоматически); ручной путь через тег/workflow_dispatch сохранён.

---

**EN:** GameCube-style controller support (NpadGc); unified default sound pack
(cleaner menu, works out of the box); libryazhahand synced with upstream libryazhahand
(camelCase rename rule, background PSC sleep poller disabled); vendored
ryazhahand-upstream bumped to v2.5.3; release pipeline can now be triggered by a
RELEASE.ini bump — tag is created automatically.


## [v2.3.0]

### Добавлено
- **Ryazha-LED** — единый модуль управления подсветкой (`source/ryazha_led/`),
  объединивший прежние liteswitch-led и sys-notif-LED. Один конфиг
  `config/ryazhahand/led.ini`, авто-детект железа (Switch Lite / Joy-Con / OLED),
  единый sysmodule с title id `0100000000000ED1`. Подробности — `docs/RYAZHA_LED.md`.
- Звуковые пакеты (WAV из ZIP в `config/ryazhahand/sounds/`).
- PNG-обои (`config/ryazhahand/wallpaper.png`, декод libpng на лету).
- Релизный `sdout.zip` — SD-card-ready бандл с ассетами, языками и nx-ovlloader.

### Исправлено
- LED не включался после загрузки консоли (убрано гашение в `__appExit`,
  повышенный retry).
- Режим OnPress теперь корректно гаснет; LED восстанавливается после boot.
- Аудио: pre-warm на старте действительно применяется; убран лишний
  `reloadSoundCacheNow` (лаг звука).
- Зависание при shutdown; корректный переход Overlays <-> Packages.

### Изменено
- Ребрендинг на аккаунт **Dimasick-git** (репозитории, ссылки, атрибуция).
- libtesla заменён на форк **libryazhahand**; nx-ovlloader подключён сабмодулем.

## [v2.2.x]

- Базовая ветка форка Ryzhand-Overlay (ppkantorski): файловые операции на SD,
  HTTPS-загрузка, правка `.ini`, hex/IPS/pchtxt патчи, запуск сторонних `.ovl`.
