# Интеграция с экосистемой Ryazha

Ryzhand Overlay — часть семейства проектов одного автора. Все они построены на общей библиотеке [libryazhahand](https://github.com/Dimanchikgshehsbshene/libryazhahand) (форк libultrahand/libtesla).

## Связанные оверлеи и модули

| Проект | Репозиторий | Роль |
|--------|-------------|------|
| **Ryzhand Overlay** | `Dimanchikgshehsbshene/Ryazhahand-Overlay` | Корневой оверлей, launcher для остальных. |
| **libryazhahand** | `Dimanchikgshehsbshene/libryazhahand` | Общая библиотека UI / утилит. |
| **RCU** | `Dimanchikgshehsbshene/RCU` | Разгон/мониторинг Tegra X1+, оверлей `ryazha-clk`. |
| **RyazhaTune** | `Dimasick-git/RyazhaTune` | Фоновый аудио-плеер. |
| **Ryazha-Status-Monitor** | `Dimasick-git/Ryazha-Status-Monitor` | Мониторинг температуры/FPS. Источник LED-модуля для Switch Lite. |

## Общий стек

```
+--------------------------------------+
|        Ryzhand Overlay (корень)      |
|  - запуск других .ovl                |
|  - управление пакетами               |
|  - LED, сканер обновлений            |
+--------------------------------------+
            |          |
            v          v
   +----------+   +-------------------+
   |   RCU    |   |  Ryazha-Status... |
   | ryazha-  |   |   (мониторинг)    |
   |  clk.ovl |   +-------------------+
   +----------+
            |
            v
   +-------------------+
   |  libryazhahand    |  <- общий fork libultrahand
   +-------------------+
```

## libryazhahand как общая зависимость

Все оверлеи семейства подключают libryazhahand через `lib/libryazhahand/ryazhahand.mk`:

```make
include ${TOPDIR}/lib/libryazhahand/ryazhahand.mk
```

Это даёт:
- Единый Tesla-runtime (`tsl::`) во всех оверлеях.
- Общие утилиты `ult::` (download, INI, JSON, hex).
- Один стиль UI: одинаковые header'ы, list items, цвета.
- Одно место для багфиксов и upstream-синков с `ppkantorski/libultrahand`.

В Ryzhand Overlay v2.3.0 библиотека пока **vendored** (лежит в репо как обычные файлы). В v2.4.0 будет вынесена в git submodule.

## Запуск других оверлеев из Ryzhand

Ryzhand работает как ovlloader-launcher: на главном экране есть раздел *Оверлеи*, где перечислены все `.ovl` в `/switch/.overlays/`. По нажатию `A` оверлей передаёт управление выбранному и сохраняет состояние, чтобы при `B` вернуться к Ryzhand.

Совместимы любые оверлеи на libtesla **и** на libryazhahand — публичный API namespace `tsl::` оставлен идентичным upstream, чтобы один и тот же .ovl работал из обоих миров.

## Sysmodule-сторона LED

Управление LED в Ryzhand v2.3.0 разбито на две части:

- **Оверлейная сторона** — `source/led/led_control.{hpp,cpp}` — записывает настройки в `/config/ryazhahand/led.ini` и сигнальные файлы `led.reload` / `led.pulse`.
- **Sysmodule-сторона** — отдельный фоновый процесс (`sys-notif-LED`, `liteswitch-led` или аналог), который читает эти файлы и непосредственно дёргает `hidsysSetNotificationLedPattern` / Joy-Con HID. Устанавливается независимо.

Без sysmodule оверлей запишет настройки, но физически LED не зажжётся.

## Обновление подмодуля libryazhahand

В будущем (v2.4.0+), когда `lib/libryazhahand` станет подмодулем:

```bash
cd lib/libryazhahand
git fetch origin
git checkout main
git pull
cd ../..
git add lib/libryazhahand
git commit -m "deps: обновить libryazhahand до <SHA>"
```

В RCU и RyazhaTune аналогично.

## Синхронизация с ppkantorski/libultrahand

Скрипт `scripts/sync_from_upstream.py` в репо `libryazhahand` пуллит коммиты с upstream и применяет к нашему дереву с inline-ребрендингом (`Ultrahand` → `Ryzhand` в визуальных строках, namespace `tsl::` не трогается). Запускается вручную или по cron.
