# extra/sysmodules/

Sysmodules, которые Ryazhahand-Overlay поставляет в `atmosphere/contents/`
вместе со своим `.ovl`. Эти модули запускаются как фоновые сервисы CFW
Atmosphere и работают парой с модулями оверлея.

## sys-notif-LED (Xc987)

- **Источник:** [Xc987/sys-notif-LED](https://github.com/Xc987/sys-notif-LED)
- **Версия по умолчанию:** `1.0.1`
- **Лицензия:** MIT (см. `SUB_LICENSE` в корне проекта)
- **Title ID:** `0100000000000895`
- **Назначение:** включает LED HOME-кнопки на буте и при подключении
  новых контроллеров. Читает режим из конфига, который пишет
  `source/ryazha_led/` нашего оверлея в `/config/ryazhahand/led.ini`.

Sysmodule **не** хранится в git. Вместо этого скрипт
[`scripts/fetch_led_sysmodule.sh`](../../scripts/fetch_led_sysmodule.sh)
скачивает свежий релиз из GitHub-релиза Xc987/sys-notif-LED во время
сборки и раскладывает по структуре SD-карты:

```
atmosphere/contents/0100000000000895/
  exefs.nsp
  flags/boot2.flag
  toolbox.json
switch/.overlays/sys-notif-LED.ovl
```

### Зачем не вендорить .nsp в git

- В репо нет бинарей: коммиты остаются маленькими.
- Версию sysmodule легко поднимать: `LED_SYSMODULE_TAG=1.0.2 make`.
- Лицензия MIT соблюдается естественным образом -- бинарь приезжает
  из upstream-источника, attribution -- в этом README и `SUB_LICENSE`.

### Локальная сборка без интернета

```sh
LED_SKIP_FETCH=1 make
```

Скрипт молча выходит, релизный ZIP получится без `atmosphere/contents/`
(оверлей останется работоспособным, просто LED не будет применяться
без отдельной установки sysmodule).

## Switch Lite

На Switch Lite Joy-Con отсутствуют и работает только power-LED через i2c.
Совместимого open-source sysmodule под Lite в публичных репозиториях
сейчас нет. Если он появится -- добавим аналогичный fetch-скрипт и
параллельный subdir здесь.
