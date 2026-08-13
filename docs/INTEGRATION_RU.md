# Интеграция с экосистемой Ryazha

Ryzhand Overlay — часть семейства проектов одного автора. Все они построены на общей библиотеке [libryazhahand](https://github.com/Dimasick-git/libryazhahand) (форк libryazhahand/libtesla).

## Связанные оверлеи и модули

| Проект | Репозиторий | Роль |
|--------|-------------|------|
| **Ryzhand Overlay** | `Dimasick-git/Ryazhahand-Overlay` | Корневой оверлей, launcher для остальных. |
| **libryazhahand** | `Dimasick-git/libryazhahand` | Общая библиотека UI / утилит. |
| **RCU** | `Dimasick-git/RCU` | Разгон/мониторинг Tegra X1+, оверлей `ryazha-clk`. |
| **RyazhaTune** | `Dimasick-git/RyazhaTune` | Фоновый аудио-плеер. |
| **Ryazha-Status-Monitor** | `Dimasick-git/Ryazha-Status-Monitor` | Мониторинг температуры/FPS. Источник LED-модуля для Switch Lite. |

## Общий стек

```
+--------------------------------------+
| Ryzhand Overlay (корень) |
| - запуск других .ovl |
| - управление пакетами |
| - LED, сканер обновлений |
+--------------------------------------+
 | |
 v v
 +----------+ +-------------------+
 | RCU | | Ryazha-Status... |
 | ryazha- | | (мониторинг) |
 | clk.ovl | +-------------------+
 +----------+
 |
 v
 +-------------------+
 | libryazhahand | <- общий fork libryazhahand
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
- Одно место для багфиксов и upstream-синков с `ppkantorski/libryazhahand`.

libryazhahand подключён как git submodule в `lib/libryazhahand/`. Обновление — стандартное:

```sh
git submodule update --remote lib/libryazhahand
git commit -am "deps: bump libryazhahand"
```

## Запуск других оверлеев из Ryzhand

Ryzhand работает как ovlloader-launcher: на главном экране есть раздел *Оверлеи*, где перечислены все `.ovl` в `/switch/.overlays/`. По нажатию `A` оверлей передаёт управление выбранному и сохраняет состояние, чтобы при `B` вернуться к Ryzhand.

Совместимы любые оверлеи на libtesla **и** на libryazhahand — публичный API namespace `tsl::` оставлен идентичным upstream, чтобы один и тот же .ovl работал из обоих миров.

## Sysmodule-сторона LED

LED-стек теперь объединён в один sysmodule `ryazha-led` (title `0100000000000ED1`), который ставится из `extra/sysmodules/ryazha-led/` вместе с оверлеем:

- **Оверлейная сторона** — `source/led/led_control.{hpp,cpp}` — записывает настройки в `/config/ryazhahand/led.ini` и сигнальный файл `led.reload`.
- **Sysmodule-сторона** — `ryazha-led.nsp` слушает touch на `led.reload`, перечитывает INI и автодетектом дёргает либо `hidsysSetNotificationLedPattern` (Joy-Con / OLED), либо GPIO PWM HOME (Switch Lite).

Раньше использовались два отдельных модуля (`sys-notif-LED`, `liteswitch-led`) — сейчас единый.

## Синхронизация с ppkantorski/libryazhahand

В `libryazhahand` есть скрипт `scripts/sync_from_upstream.py` который пуллит коммиты с upstream'а и применяет к нашему дереву с inline-ребрендингом (`Ryzhand` → `Ryzhand` в визуальных строках, namespace `tsl::` не трогается). Запуск только вручную после code-review (cron убран, чтобы не ломал нашу subdir-структуру).

---
Автор: **Dimasick-git**
