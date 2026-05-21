# Ryazha-LED

Единый модуль управления подсветкой Switch внутри Ryazhahand-Overlay.

- Автор: **Dimasick-git**
- Лицензия: **GPL-2.0**
- Версия: **2.3.0**
- Расположение в коде: `source/ryazha_led/`

## Зачем нужен

Раньше в моей экосистеме было два отдельных решения:

- **liteswitch-led** -- модуль физического LED HOME-кнопки для Switch Lite,
  взятый из Ryazha-Status-Monitor.
- **sys-notif-LED** -- управление Joy-Con player-LED, использовалось в
  RyazhaTune.

Это создавало дубли: в каждом оверлее свой UI, свой формат конфигов,
свой триггер перезагрузки. `Ryazha-LED` объединяет их в один модуль:

- Один конфиг: `sdmc:/config/ryazhahand/led.ini`.
- Один триггер reload: `sdmc:/config/ryazhahand/led.reload` (touch-файл,
  любой sysmodule может его прочитать).
- Один публичный API из C++: `ryz::led::*`.
- Авто-детект железа: на Switch Lite модуль шлёт настройки в `liteswitch-led`,
  на обычной/OLED -- в `sys-notif-LED`. Пользователь не выбирает руками.

Overlay при этом сам с железом не разговаривает: только пишет INI и
триггер -- так настройки переживают перезагрузку, и любой совместимый
sysmodule может их подхватить.

## Структура файлов

```
source/ryazha_led/
  ryazha_led.hpp   -- публичный API
  ryazha_led.cpp   -- реализация
```

В `Makefile` папка добавлена в `SOURCES` и `INCLUDES`.

## Публичный API (`namespace ryz::led`)

```cpp
enum class Mode : uint8_t {
    Off     = 0,  // подсветка выключена
    Solid   = 1,  // ровное свечение
    Pulse   = 2,  // пульсация
    Fade    = 3,  // плавное затухание/нарастание
    OnPress = 4,  // короткий импульс при нажатии кнопки
};

enum class Target : uint8_t {
    Auto       = 0,  // авто-детект: на Lite -- все LED, иначе Joy-Con
    HomeButton = 1,  // только LED кнопки HOME
    JoyConL    = 2,
    JoyConR    = 3,
};

struct Settings {
    Mode    mode;
    Target  target;
    uint8_t intensity;   // 0..255
    uint8_t r, g, b;     // цвет (если поддерживается железом)
};

bool isLite();                      // авто-детект Switch Lite
bool load(Settings& out);           // прочитать led.ini, false если файла нет
bool save(const Settings& s);       // записать led.ini + триггер reload
void touchReloadTrigger();          // только триггер, без записи
const char* modeName(Mode m);       // локализованное имя для UI
const char* targetName(Target t);   // локализованное имя для UI
```

## INI-формат

```ini
# sdmc:/config/ryazhahand/led.ini  -- пишется Ryazhahand-Overlay,
# читается sys-notif-LED / liteswitch-led.
[led]
mode      = pulse           # off | solid | pulse | fade | onpress
target    = auto            # auto | home | joyconL | joyconR
intensity = 180             # 0..255
color_r   = 255
color_g   = 64
color_b   = 0
updated_at = 2026-05-20T17:32:11Z
```

`updated_at` пишется автоматически в UTC ISO-8601 -- удобно для отладки
"sysmodule подхватил последние настройки?".

## Интеграция в UI

В меню `Прочее` Ryazhahand-Overlay добавляется пункт `Подсветка LED`,
который вызывает `ryz::led::load` для текущих настроек и `ryz::led::save`
после применения. На Switch Lite автоматически скрываются неактуальные
опции (например, выбор Joy-Con).

## Совместимость с экосистемой

- **Ryazhahand-Overlay** (v2.3.0+) -- пишет настройки в `led.ini`.
- **sys-notif-LED** ([Xc987/sys-notif-LED](https://github.com/Xc987/sys-notif-LED), MIT) --
  фоновый sysmodule, применяет настройки на железе. Поставляется в нашем
  релизе автоматически: при `make` скрипт
  [`scripts/fetch_led_sysmodule.sh`](../scripts/fetch_led_sysmodule.sh)
  скачивает свежий релиз и кладёт в `out/atmosphere/contents/0100000000000895/`.
  В git репозитории бинарь не хранится -- описание в
  [`extra/sysmodules/README.md`](../extra/sysmodules/README.md), MIT-attribution
  в [`extra/sysmodules/sys-notif-LED.LICENSE`](../extra/sysmodules/sys-notif-LED.LICENSE).
- **liteswitch-led** -- модуль для Switch Lite. Совместимого open-source
  проекта в публичных репах пока нет; добавим аналогичный fetch-скрипт
  как только появится.
- **RyazhaTune** -- может читать тот же `led.ini` для синхронизации UI.

### Локальная сборка без интернета

CI и обычный `make` тянут sysmodule через `scripts/fetch_led_sysmodule.sh`.
Если интернета на машине нет, отключите автозагрузку:

```sh
LED_SKIP_FETCH=1 make
```

Релизный ZIP получится без `atmosphere/contents/` -- оверлей и
`led.ini` останутся, просто LED не будет применяться, пока sysmodule
не установят вручную.

API стабилен с версии 2.3.0; добавление новых полей идёт только append-only
в `Settings` чтобы не сломать форматы существующих INI.

## Лицензия

GPL-2.0 (см. `LICENSE` в корне Ryazhahand-Overlay).
