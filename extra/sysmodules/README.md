# extra/sysmodules/

Sysmodules, которые Ryazhahand-Overlay поставляет в `atmosphere/contents/`
вместе со своим `.ovl`. Эти модули запускаются как фоновые сервисы CFW
Atmosphere и работают парой с UI-секцией "Свечение LED" нашего оверлея.

## ryazha-led (объединённый sysmodule)

- **Title ID:** `0100000000000ED1`
- **Лицензия:** MIT (см. `ryazha-led/LICENSE`)
- **Source:** вендорится прямо в `ryazha-led/source/`, собирается на
  CI скриптом `scripts/build_ryazha_led.sh`.
- **Конфиг:** `/config/ryazhahand/led.ini` (пишется UI оверлея).
- **Reload-trigger:** `/config/ryazhahand/led.reload` (touch-файл).

### Как работает

При старте sysmodule вызывает `setsysGetProductModel` и выбирает
платформо-зависимую ветку:

| Железо                          | Бэкенд                  |
|---------------------------------|-------------------------|
| Switch Lite (`SetSysProductModel_Hoag`) | GPIO pad Y,5 (PWM на notification LED Lite) |
| Erista / Mariko / OLED          | `hidsysSetNotificationLedPattern` для Joy-Con notification LED |

Один и тот же `led.ini` обслуживает обе ветки. Никакого ручного
выбора платформы пользователю делать не нужно.

### Слияние двух исходников

Bo вместо двух разных бинарей в atmosphere/contents/ (как было раньше),
теперь один. Логика объединена из двух MIT-проектов:

- [liteswitch](https://github.com/zachvanwelzen/liteswitch) -- GPIO
  PWM control для Switch Lite, copyright Zach van Welzen.
- [sys-notif-LED](https://github.com/Xc987/sys-notif-LED) -- hidsys
  notification LED для обычной Switch / OLED, copyright Xc987.

Атрибуция MIT в `ryazha-led/LICENSE`.

### Локальная сборка без интернета

```sh
LED_SKIP_FETCH=1 make
```

(переменная общая для исторических LED-скриптов, имя сохранили). Skip
просто пропускает шаг сборки sysmodule -- релизный ZIP получится с
`switch/.overlays/ovlmenu.ovl` + локали, но без
`atmosphere/contents/0100000000000ED1/`. Без sysmodule UI Ryazha-LED
будет писать `led.ini`, а на железо изменения не пойдут, пока
sysmodule не установлен.

### Что лежит внутри `ryazha-led/`

```
extra/sysmodules/ryazha-led/
  Makefile               -- devkitpro-based, $(TARGET) = ryazha-led
  ryazha-led.json        -- NPDM config + title id 0100000000000ED1
  toolbox.json           -- meta для overlay-инсталляторов
  LICENSE                -- MIT + attribution upstream-проектам
  source/main.cpp        -- auto-detect + GPIO/hidsys диспетчер
```

### Старые отдельные sysmodule'и

Раньше в дистрибутиве были два независимых бинаря:
`atmosphere/contents/0100000000000895/` (sys-notif-LED) и
`atmosphere/contents/0100000000000FED/` (liteswitch). Они больше **не
поставляются** -- объединены в `0100000000000ED1`. При обновлении с
старого релиза нужно удалить руками две старые папки contents, чтобы
не плодить два параллельных sysmodule'а, дёргающих один и тот же LED.
