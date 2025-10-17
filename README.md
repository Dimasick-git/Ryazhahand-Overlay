#Ryazhahand Overlay (HOS 16.0.0+) позволяет запускать кастомные команды при загрузке через `/switch/.packages/boot_package.ini` (секция `boot`).

🚀 Начало работы:

1.  Установите nx-ovlloader или nx-ovlloader+ (nx-ovlloader+ требует на 2MB больше памяти, но предоставляет расширенные функции; переключение в настройках Ryazhahand).
2.  Скачайте `ovlmenu.ovl` и поместите в `/switch/.overlays/` (это перезапишет Tesla Menu).
3.  После установки появится папка `/config/ultrahand/` с файлом `config.ini` (базовые настройки Ryazhahand).
4.  Запустите Ryazhahand через ZL + ZR + ↓ (или Tesla). Будет создана папка `/switch/.packages/` с шаблонным `package.ini`.
5.  Поместите свой `package.ini` в `/switch/.packages/<PACKAGE_NAME>/`. Он содержит команды для вашего пакета.
6.  Если пакет не отображается — запустите Fix Bit Archive в Hekate.
7.  Готовые решения: Ultrahand Packages.

Команды появятся в меню пакетов Ryazhahand.

⚙️ Дополнительные функции:

*   A — запуск команды.
*   MINUS — просмотр и запуск отдельных строк из `ini`.
*   PLUS — вход в настройки.
*   X — избранное.
*   Y — конфигурация пакета/оверлея.

Подробная информация: Ryazhahand Wiki.

🎮 Совместимость:

Требуется Atmosphere и HOS 16.0.0+. После установки окружения можно запускать `.ovl` через Tesla.

⚠️ Использование homebrew может аннулировать гарантию.

🧱 Зависимости для компиляции:

| Библиотека    | Ссылка на исходники |
| ------------- | ------------------- |
| libultrahand  | GitHub              |
| libnx         | GitHub              |
| switch-curl   | curl.se             |
| switch-zlib   | zlib.net            |
| switch-mbedtls | GitHub              |

Рекомендуемая установка через devkitPro:

```bash
sudo pacman -S switch-dev switch-libnx switch-curl switch-zlib switch-mbedtls
```

🤝 Вклад:

*   Создать issue
*   Сравнить и отправить PR
*   Обсуждение на GBATemp

📜 Лицензия:

GPLv2 (libultrahand под CC-BY-4.0).

© 2025 Dimasick-git
