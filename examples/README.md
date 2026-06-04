# Примеры пакетов Ryzhand

Набор готовых `.ini`-пакетов в формате Ryzhand. Все они — обычные папки с `package.ini`, читаемые в формате описанном в [`../docs/PACKAGES_RU.md`](../docs/PACKAGES_RU.md). Можно копировать в `/switch/.packages/` на SD-карту и запускать прямо из меню Ryzhand.

## Список

- **Broomstick** — очистка SD от мусорных файлов (логи, кеш Tinfoil и т.д.).
- **Cool Curves** — кривые охлаждения, читает данные о температуре из RCU.
- **Easy Installer** — мастер установки сторонних оверлеев (загрузка из GitHub releases + распаковка в `switch/.overlays/`).
- **Host Guard** — блокировка телеметрии Nintendo через правку `/atmosphere/hosts`.
- **Memory Config** — конфигурация RAM-таймингов через KIP-патч (взаимодействует с RCU).
- **Mod Master** — установка IPS / pchtxt модов в `/atmosphere/exefs_patches/`.
- **OC Toolkit** — управление разгоном (тонкая интеграция с RCU IPC).
- **l4t_reboot** — перезагрузка в Linux4Tegra через chainload boot config.

У большинства внутри есть собственный `README.md` с подробностями.

## Использование как стартовый шаблон

Скопировать любую папку в `/switch/.packages/MyPackage/`, открыть `package.ini`, заменить команды на свои. Ryzhand подхватит пакет в меню после перезапуска.

---
Автор (Ryzha-адаптация): Dimasick-git
