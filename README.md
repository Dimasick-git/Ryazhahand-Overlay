Ryazhahand Overlay (HOS 16.0.0+)
— Поддержка кастомных автозагрузочных команд через /switch/.packages/boot_package.ini с секцией boot. Позволяет запускать цепочку команд сразу после загрузки устройства.

🚀 Начало работы
Использование
Установи nx-ovlloader или nx-ovlloader+.

nx-ovlloader+ требует на 2MB больше памяти, но предоставляет расширенные функции. Переключение между версиями доступно в меню настроек Ryazhahand.

Скачай ovlmenu.ovl и помести в /switch/.overlays/.

⚠️ Это перезапишет Tesla Menu, если он установлен.

После установки появится папка /config/ultrahand/ с config.ini — базовые настройки Ryazhahand.

Запусти Ryazhahand через хоткей ZL + ZR + ↓ (или Tesla). Будет создана папка /switch/.packages/ с шаблонным package.ini.

Помести свой package.ini в /switch/.packages/<PACKAGE_NAME>/. Он содержит команды для твоего кастомного пакета.

Если пакет не отображается — запусти Fix Bit Archive в Hekate.

Смотри Ultrahand Packages для готовых решений.

Команды появятся в меню пакетов Ryazhahand.

⚙️ Дополнительные функции
A — запуск команды.

MINUS — просмотр и запуск отдельных строк из ini.

PLUS — вход в настройки.

X — избранное.

Y — конфигурация пакета/оверлея.

Для расширенной информации — Ryazhahand Wiki.

🎮 Совместимость
Требуется Atmosphere и прошивка HOS 16.0.0+. После установки окружения можно запускать .ovl через хоткей Tesla.

⚠️ Использование homebrew может аннулировать гарантию. Работай осознанно.

🧱 Зависимости для компиляции
Установи следующие C/C++ библиотеки:

Библиотека	Ссылка на исходники
libultrahand	GitHub
libnx	GitHub
switch-curl	curl.se
switch-zlib	zlib.net
switch-mbedtls	GitHub
💡 Рекомендуется установка через devkitPro:

bash
sudo pacman -S switch-dev switch-libnx switch-curl switch-zlib switch-mbedtls
🤝 Вклад
Открыт к предложениям, багрепортам и пулл-реквестам:

Создать issue

Сравнить и отправить PR

Обсуждение на GBATemp

📜 Лицензия
Проект распространяется под GPLv2, с кастомной библиотекой libultra под CC-BY-4.0.

© 2025 Dimasick-git
