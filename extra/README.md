# extra/

Сторонние утилиты вокруг Ryazhahand-Overlay. Часть исполняется на ПК, часть — sysmodules в `atmosphere/contents/`.

## Скрипты для ПК

- `pchtxt2ips.py` — конвертер pchtxt модов в IPS.
- `rar2zip.py` — конвертация .rar архивов модов в .zip (Ryzhand читает только zip).
- `ryazhahand_notify.py` — отправка push-уведомлений в Ryazhand по HTTP (для интеграции с домашней автоматизацией).

Запускаются под Python 3.10+, требуют только stdlib.

## Sysmodules

См. [`sysmodules/README.md`](sysmodules/README.md). Главный — `ryazha-led` (управление подсветкой Joy-Con / Switch Lite HOME).
