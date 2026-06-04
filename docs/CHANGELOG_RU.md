# Changelog

Все заметные изменения Ryazhahand-Overlay. Формат заголовков `## [vX.Y.Z]`
используется workflow'ом релиза (`.github/workflows/release.yml`) для
автоизвлечения заметок к релизу.

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

- Базовая ветка форка Ultrahand-Overlay (ppkantorski): файловые операции на SD,
  HTTPS-загрузка, правка `.ini`, hex/IPS/pchtxt патчи, запуск сторонних `.ovl`.
