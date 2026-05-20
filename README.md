# Ryzhand Overlay (HOS 16.0.0+)

[![platform](https://img.shields.io/badge/platform-Switch-898c8c?logo=C++.svg)](https://gbatemp.net/forums/nintendo-switch.283/?prefix_id=44)
[![language](https://img.shields.io/badge/language-C++-ba1632?logo=C++.svg)](https://github.com/topics/cpp)
[![GPLv2 License](https://img.shields.io/badge/license-GPLv2-189c11.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
[![Latest Version](https://img.shields.io/github/v/release/Dimanchikgshehsbshene/Ryazhahand-Overlay?label=latest&color=blue)](https://github.com/Dimanchikgshehsbshene/Ryazhahand-Overlay/releases/latest)
[![GitHub Downloads](https://img.shields.io/github/downloads/Dimanchikgshehsbshene/Ryazhahand-Overlay/total?color=6f42c1)](https://github.com/Dimanchikgshehsbshene/Ryazhahand-Overlay/releases)
[![HB App Store](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/Dimanchikgshehsbshene/Ryazhahand-Overlay/main/.github/hbappstore.json&label=hb%20app%20store&color=6f42c1)](https://hb-app.store/switch/RyzhandOverlay)
[![GitHub issues](https://img.shields.io/github/issues/Dimanchikgshehsbshene/Ryazhahand-Overlay?color=222222)](https://github.com/Dimanchikgshehsbshene/Ryazhahand-Overlay/issues)
[![GitHub stars](https://img.shields.io/github/stars/Dimanchikgshehsbshene/Ryazhahand-Overlay)](https://github.com/Dimanchikgshehsbshene/Ryazhahand-Overlay/stargazers)

Гибкое управление файлами, каталогами и системными настройками на Switch — через простые `.ini`-пакеты.

[![Ryzhand Logo](.pics/banner.gif)](https://github.com/Dimanchikgshehsbshene/Ryazhahand-Overlay)

**Ryzhand Overlay** — это меню-оверлей и интерпретатор команд, построенный на форке [libtesla](https://github.com/WerWolv/libtesla) — нашей [libryazhahand](https://github.com/Dimanchikgshehsbshene/libryazhahand). Запускается через [Tesla-меню](https://github.com/WerWolv/Tesla-Menu) или совместимый ovlloader. Поддерживает свой компактный язык-скрипт (похожий на shell/BAT), в котором описываются пакеты — единицы автоматизации.

## Что умеет

- **Каталоги** — создаёт/копирует/перемещает/удаляет файлы и папки на SD.
- **Скачивание** — забирает файлы по URL прямо в оверлее, поддерживает HTTPS.
- **Распаковка** — `.zip` распаковывается без выхода в HBL.
- **INI** — правит произвольные конфиги: ключи, значения, секции.
- **Hex-патчи** — точечные правки бинарей по смещению.
- **Конвертация модов** — IPS, pchtxt, и сопутствующие форматы.
- **Запуск других оверлеев** — Ryzhand работает как корневой launcher.
- **Управление подсветкой** *(v2.3.0)* — модуль [Ryazha-LED](docs/RYAZHA_LED.md): LED HOME-кнопки и Joy-Con, авто-детект Switch Lite vs обычной/OLED. Режимы Off / Постоянно / Пульсация / Плавный / При нажатии. Сам с железом не общается -- пишет `/config/ryazhahand/led.ini`, который читает фоновый sysmodule (`sys-notif-LED` для обычной Switch, `liteswitch-led` для Lite).
- **Сканер обновлений** *(v2.3.0, опциональный)* — сравнивает локальные `.ovl` с релизами на GitHub. Выключен по умолчанию: в v2.3.0 работает синхронно и может задерживать загрузку пакетов, в v2.4.0 запланирован вынос в отдельный поток с 6-часовым кэшем.
- **Локализация** — основной язык русский, опционально английский. Файлы переводов в `lang/`.

## Скриншоты

![Слайдшоу](.pics/slideshow.gif)

## Установка

1. Скачайте `Ryzhand-Overlay-vX.Y.Z.zip` из [последнего релиза](https://github.com/Dimanchikgshehsbshene/Ryazhahand-Overlay/releases/latest).
2. Распакуйте архив в корень SD-карты — структура совпадает с `/switch/.overlays/` и `/config/ryazhahand/`.
3. Убедитесь что установлен совместимый ovlloader (Atmosphere ≥ 1.6, HOS ≥ 16.0).
4. Откройте Tesla-меню (`+`) и запустите **Ryzhand** из списка.

Для пользователей предыдущих версий: конфиг автоматически мигрирует с `/config/ultrahand/` на `/config/ryazhahand/` (если папка `ultrahand` есть — её нужно вручную перенести).

## Требования

| Компонент | Версия |
|-----------|--------|
| Atmosphere CFW | ≥ 1.6.0 |
| HOS (firmware) | ≥ 16.0.0 |
| ovlloader / Tesla | актуальный |
| SD карта | exFAT/FAT32, ≥ 100 МБ свободно |

## Сборка из исходников

Нужны [devkitPro](https://devkitpro.org/) с `devkitA64`, `libnx`, `switch-curl`, `switch-zlib`, `switch-minizip`, `switch-mbedtls`, `switch-libpng`.

```bash
git clone https://github.com/Dimanchikgshehsbshene/Ryazhahand-Overlay.git
cd Ryazhahand-Overlay
export DEVKITPRO=/opt/devkitpro
make -j$(nproc)
```

Результат — `ovlmenu.ovl` в корне и стейджированная SD-структура в `out/`.

Подробнее о структуре пакетов: [`docs/PACKAGES_RU.md`](docs/PACKAGES_RU.md).

## Документация

- [`docs/UI_RU.md`](docs/UI_RU.md) — описание экранов и навигации.
- [`docs/PACKAGES_RU.md`](docs/PACKAGES_RU.md) — формат `package.ini` и список команд.
- [`docs/INTEGRATION_RU.md`](docs/INTEGRATION_RU.md) — как подключать сторонние оверлеи и взаимодействие с RCU / RyazhaTune.
- [`docs/CHANGELOG_RU.md`](docs/CHANGELOG_RU.md) — что изменилось от релиза к релизу.
- [`docs/RYAZHA_LED.md`](docs/RYAZHA_LED.md) — модуль управления подсветкой.

## Связанные проекты

| Проект | Назначение |
|--------|-----------|
| [libryazhahand](https://github.com/Dimanchikgshehsbshene/libryazhahand) | Форк libultrahand/libtesla — основа оверлея, используется и в смежных проектах. |
| [RCU](https://github.com/Dimanchikgshehsbshene/RCU) | Разгон/мониторинг Tegra X1+ — оверлей `ryazha-clk`. |
| [RyazhaTune](https://github.com/Dimasick-git/RyazhaTune) | Фоновый аудиоплеер, форк sys-tune. |
| [Ryazha-Status-Monitor](https://github.com/Dimasick-git/Ryazha-Status-Monitor) | Мониторинг температуры/FPS, источник модуля LED-Lite. |

Все эти проекты используют один и тот же `libryazhahand` — обновления библиотеки прилетают сразу везде.

## Благодарности

Этот проект — глубокий форк замечательного [Ultrahand-Overlay](https://github.com/ppkantorski/Ultrahand-Overlay) автора **ppkantorski**. Без его исходной работы Ryzhand был бы невозможен. Также спасибо:

- [WerWolv](https://github.com/WerWolv) — за libtesla и Tesla-меню.
- [HookedBehemoth](https://github.com/HookedBehemoth) — за sys-tune (база RyazhaTune).
- Авторам `sys-notif-LED` и `liteswitch-led` — за модули управления подсветкой.

## Лицензия

GPLv2 — см. [`LICENSE`](LICENSE). На отдельные подмодули и зависимости распространяются их собственные лицензии — см. [`SUB_LICENSE`](SUB_LICENSE).

Автор форка: **Dimasick-git**.
Хостинг и автоматические релизы: **Dimanchikgshehsbshene/Ryazhahand-Overlay**.
