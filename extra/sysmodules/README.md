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

## liteswitch (Zach van Welzen)

- **Источник:** vendored в `extra/sysmodules/liteswitch/` (upstream:
  Zach van Welzen, MIT)
- **Лицензия:** MIT (см. `liteswitch.LICENSE` и `liteswitch/LICENSE`)
- **Title ID:** `0100000000000FED`
- **Назначение:** управление HOME-кнопкой LED на Switch Lite. Sysmodule
  + собственный overlay управления (`liteswitch.ovl`) -- работает с
  отдельным конфигом `/config/led-control/`, не с нашим `led.ini`.

Source-код **вендорится** в репо (в отличие от sys-notif-LED, который
просто скачивается): он маленький (~60K), и пересобирать его на месте
devkitpro toolchain'ом дешевле, чем тянуть готовый zip каждый раз.

Сборка:

```sh
bash scripts/build_lite_led.sh out/
```

Скрипт делает `make all` в копии vendored-источников, кладёт
`atmosphere/contents/0100000000000FED/exefs.nsp` + flag + toolbox +
`switch/.overlays/liteswitch.ovl` в `out/`. Требует
`DEVKITPRO=/opt/devkitpro` (есть в CI-контейнере). При
`LED_SKIP_FETCH=1` шаг молча пропускается.

### Сосуществование с sys-notif-LED

Оба sysmodule попадают в один dist, у них разные title IDs (0895 vs
FED). Atmosphere стартует оба; на обычной Switch / OLED работает 0895,
на Switch Lite -- FED. Никаких ручных переключений не требуется.

### Интеграция с Ryazha-LED

Сейчас liteswitch использует **свой** INI (`/config/led-control/`),
а наш Ryazha-LED -- свой (`/config/ryazhahand/led.ini`). На Lite это
значит, что наш UI настройки LED в Ryazhahand-Overlay физически
ничего не применит -- нужно либо использовать поставляемый
`liteswitch.ovl`, либо адаптировать Ryazha-LED, чтобы он на Lite ещё
и писал в `/config/led-control/`. Последнее в TODO.
