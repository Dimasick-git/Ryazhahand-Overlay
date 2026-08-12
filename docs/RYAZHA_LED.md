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
    LiteAll    = 4,  // Switch Lite -- единственный сегмент LED
};

struct Settings {
    Mode     mode            = Mode::Off;
    Target   target          = Target::Auto;
    uint8_t  brightness      = 80;    // 0..100 %
    uint32_t pulseIntervalMs = 500;   // период пульсации, мс
    uint8_t  colorR = 0xFF, colorG = 0xFF, colorB = 0xFF; // RGB для Joy-Con LED
};

bool isLiteDetected();                  // авто-детект Switch Lite
Settings load();                        // прочитать led.ini (defaults если файла нет)
bool save(const Settings& s);           // записать led.ini + триггер reload
const char* modeName(Mode m);           // локализованное имя для UI
const char* targetName(Target t);       // локализованное имя для UI
```

## INI-формат

```ini
# sdmc:/config/ryazhahand/led.ini  -- пишется Ryazhahand-Overlay,
# читается sys-notif-LED / liteswitch-led.
mode           = pulse      # off | solid | pulse | fade | onpress
target         = auto       # auto | home | joyconL | joyconR | lite_all
brightness     = 80         # 0..100 (%)
pulse_interval = 500        # период пульсации, мс
color_r        = 255
color_g        = 64
color_b        = 0
```

Файл пишется как плоский `key=value` (без секции `[led]`); строки с `#`
или `;` в начале считаются комментариями. Неизвестные ключи парсер
пропускает. `brightness` клампится в диапазон `0..100` при чтении.

## Интеграция в UI

В меню `Прочее` Ryazhahand-Overlay добавляется пункт `Подсветка LED`,
который вызывает `ryz::led::load` для текущих настроек и `ryz::led::save`
после применения. На Switch Lite автоматически скрываются неактуальные
опции (например, выбор Joy-Con).

## Совместимость с экосистемой

- **Ryazhahand-Overlay** (v2.3.0+) -- пишет настройки в `led.ini`.
- **Ryazha-LED sysmodule** -- единый фоновый сервис, sammelt оба
  старых отдельных модуля (sys-notif-LED и liteswitch) в одном бинаре
  с title id `0100000000000ED1`. Sами выбирает GPIO-ветку (Lite) или
  hidsys-ветку (обычная/OLED) через `setsysGetProductModel`. Source
  вендорится в [`extra/sysmodules/ryazha-led/`](../extra/sysmodules/ryazha-led/),
  собирается на CI скриптом
  [`scripts/build_ryazha_led.sh`](../scripts/build_ryazha_led.sh) и
  кладётся в `out/atmosphere/contents/0100000000000ED1/`.
  MIT-attribution для обоих upstream-проектов в
  [`extra/sysmodules/ryazha-led/LICENSE`](../extra/sysmodules/ryazha-led/LICENSE).
- **RyazhaTune** -- может читать тот же `led.ini` для синхронизации UI.

### Локальная сборка без интернета

CI и обычный `make` собирают sysmodule через
`scripts/build_ryazha_led.sh`. Если devkitpro не установлен или нет
интернета (хотя в этом случае ничего скачивать и не нужно), отключите
шаг:

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
