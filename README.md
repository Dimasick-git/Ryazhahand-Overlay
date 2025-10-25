![Ryazhahand Overlay Banner](.pics/Ryazhahand.png)

<div align="center">

# 🎮 Ryazhahand Overlay

### Мощный оверлей-менеджер для Nintendo Switch

[![License](https://img.shields.io/badge/License-GPL--2.0-blue.svg)](LICENSE)
[![Release](https://img.shields.io/badge/version-2.1.5-brightgreen.svg)](https://github.com/Dimasick-git/Ryazhahand-Overlay/releases)
[![Build](https://img.shields.io/badge/build-stable-success.svg)](#)
[![Support](https://img.shields.io/badge/Support-Ko--fi-ff5e5b.svg)](https://ko-fi.com/Dimasick-git)

[🚀 Установка](#-установка) • [✨ Возможности](#-возможности) • [📖 Использование](#-использование) • [🔄 Обновление](#-обновление) • [💬 Контакты](#-контакты)

</div>

---

## 📋 Описание

**Ryazhahand Overlay** — это форк популярного проекта Ultrahand, полностью переработанный и оптимизированный для стабильной работы на Nintendo Switch. Проект представляет собой мощный инструмент управления оверлеями с расширенным функционалом и современным дизайном.

### 🎯 Ключевые отличия от Ultrahand:

- ✅ **Стабильная сборка** — исправлены все критические баги
- 🔁 **Полная замена** `ULTRAHAND_*` → `RYAZHAHAND_*` во всем коде
- 🛠️ **Устранены конфликты** constexpr строк
- 📦 **Пересобран и подписан** `ovlmenu.ovl`
- 🔄 **Автообновление** прямо через консоль
- 🎨 **Новые темы** и улучшенный интерфейс
- 🌐 **Поддержка языков** включая русский

---

## ✨ Возможности

### 🔥 Основной функционал

- **📱 Меню оверлеев** — быстрый доступ ко всем установленным оверлеям
- **⚙️ Управление системой** — расширенные настройки консоли
- **🎮 Профили игр** — сохранение и загрузка конфигураций
- **📦 Менеджер пакетов** — установка и удаление модулей
- **🔧 Скрипты** — автоматизация задач через `.ini` файлы
- **🎨 Темы оформления** — кастомизация интерфейса
- **📊 Мониторинг** — отслеживание системных ресурсов
- **🗂️ Файловый менеджер** — работа с SD картой

### 🆕 Октябрьские обновления (v2.1.5)

- ✨ Добавлена система автообновления через консоль
- 🔧 Исправлены все конфликты constexpr в кодовой базе
- 🎯 Улучшена стабильность работы на всех прошивках
- 📦 Обновлена библиотека libRYAZHAHAND
- 🌐 Расширена поддержка языков
- 🎨 Добавлены новые темы оформления
- ⚡ Оптимизирована производительность
- 🐛 Исправлено более 15 багов

---

## 🚀 Установка

### Требования

- Nintendo Switch с CFW (Atmosphère рекомендуется)
- Tesla Menu (nx-ovlloader)
- SD карта с достаточным местом (~5MB)

### Быстрая установка

1. **Скачайте последний релиз:**
   ```
   https://github.com/Dimasick-git/Ryazhahand-Overlay/releases/latest
   ```

2. **Распакуйте архив** на корень SD карты:
   ```
   /switch/.overlays/ovlmenu.ovl
   /switch/.packages/Ryazhahand/
   /config/ryazhahand/
   ```

3. **Перезапустите консоль** или перезагрузите Tesla Menu

4. **Откройте Tesla Menu** (L + DPad Down + R3) и выберите Ryazhahand

### Сборка из исходников

```bash
# Клонируйте репозиторий с подмодулями
git clone --recursive https://github.com/Dimasick-git/Ryazhahand-Overlay.git
cd Ryazhahand-Overlay

# Установите DevkitPro и библиотеки
# Следуйте инструкциям: https://devkitpro.org/wiki/Getting_Started

# Соберите проект
make

# Результат: ovlmenu.ovl
```

---

## 📖 Использование

### Основные комбинации клавиш

| Комбинация | Действие |
|------------|----------|
| `L + DPad Down + R3` | Открыть Tesla Menu |
| `A` | Выбрать / Подтвердить |
| `B` | Назад / Отмена |
| `X` | Дополнительные опции |
| `Y` | Поиск / Фильтр |
| `L / R` | Переключение вкладок |

### Создание скриптов

Создайте файл `config/ryazhahand/packages/my_script.ini`:

```ini
[My Script]
# Описание скрипта
description=Пример пользовательского скрипта

# Команды
mkdir /config/custom/
copy /file.txt /config/custom/file.txt
delete /old_file.txt
reboot
```

### Настройка тем

Темы находятся в `config/ryazhahand/themes/`. Пример структуры:

```ini
[theme]
name=Custom Theme
background=#1a1a1a
foreground=#ffffff
accent=#00ff00
```

---

## 🔄 Обновление

### Автоматическое обновление (рекомендуется)

1. Откройте **Ryazhahand Overlay**
2. Перейдите в раздел **Settings → Updates**
3. Нажмите **Check for Updates**
4. Следуйте инструкциям на экране

### Ручное обновление

1. Скачайте новую версию с [Releases](https://github.com/Dimasick-git/Ryazhahand-Overlay/releases)
2. Замените файлы на SD карте
3. Перезапустите консоль

**💡 Совет:** Сделайте резервную копию конфигурации перед обновлением!

---

## 🎨 Примеры

Более подробные примеры использования доступны в папке [`examples/`](examples/) с собственным README.

### Популярные кейсы использования:

- 🎮 **Быстрое переключение профилей** для разных игр
- 📦 **Установка модов** через пакетный менеджер
- 🔧 **Автоматизация задач** с помощью скриптов
- 📊 **Мониторинг системы** в реальном времени
- 🗂️ **Управление файлами** без выключения игры

---

## 🛠️ Разработка

### Структура проекта

```
Ryazhahand-Overlay/
├── source/          # Исходный код на C++
├── lib/             # Библиотеки (libRYAZHAHAND)
├── build/           # Файлы сборки
├── themes/          # Темы оформления
├── lang/            # Языковые файлы
├── examples/        # Примеры использования
├── payloads/        # Payload файлы
└── .pics/           # Изображения и ресурсы
```

### Зависимости

- [DevkitPro](https://devkitpro.org/) — toolchain для Switch
- [libnx](https://github.com/switchbrew/libnx) — библиотеки Nintendo Switch
- [libRYAZHAHAND](https://github.com/Dimasick-git/libRYAZHAHAND) — основная библиотека проекта

### Участие в разработке

Мы приветствуем Pull Request'ы! Перед отправкой:

1. Форкните репозиторий
2. Создайте ветку для изменений (`git checkout -b feature/amazing-feature`)
3. Закоммитьте изменения (`git commit -m 'Add amazing feature'`)
4. Запушьте ветку (`git push origin feature/amazing-feature`)
5. Откройте Pull Request

Пожалуйста, соблюдайте [Code of Conduct](CODE_OF_CONDUCT.md).

---

## 📝 История изменений

### v2.1.5 (Октябрь 2024)
- ✅ Стабильная сборка с исправленными багами
- 🔁 Полная замена ULTRAHAND_* на RYAZHAHAND_*
- 🛠️ Устранены конфликты constexpr строк
- 📦 Пересобран и подписан ovlmenu.ovl
- 🔄 Добавлено автообновление через консоль
- 🎨 Новые темы и улучшенный UI
- 🌐 Расширенная языковая поддержка

Полный список изменений: [CHANGELOG](https://github.com/Dimasick-git/Ryazhahand-Overlay/releases)

---

## 💬 Контакты

### Поддержка проекта

- 💰 **Ko-fi**: [Dimasick-git](https://ko-fi.com/Dimasick-git)
- ⭐ **GitHub**: Поставьте звезду репозиторию!
- 🐛 **Issues**: [Сообщить о баге](https://github.com/Dimasick-git/Ryazhahand-Overlay/issues)
- 💡 **Discussions**: [Обсуждения](https://github.com/Dimasick-git/Ryazhahand-Overlay/discussions)

### Связь с разработчиком

- **GitHub**: [@Dimasick-git](https://github.com/Dimasick-git)
- **Issues**: Для багов и предложений

---

## 📄 Лицензии

Этот проект распространяется под двойной лицензией:

- **Код**: [GPL-2.0](LICENSE) — GNU General Public License v2.0
- **Документация и медиа**: [CC-BY-4.0](SUB_LICENSE) — Creative Commons Attribution 4.0

### Благодарности

- **Ultrahand** — оригинальный проект, послуживший основой
- **Tesla Menu** — система оверлеев для Switch
- **Atmosphère Team** — за потрясающий CFW
- **DevkitPro** — за инструменты разработки
- **Все контрибьюторы** — спасибо за вклад! ❤️

---

## ⚠️ Дисклеймер

Этот проект предназначен исключительно для образовательных целей. Разработчики не несут ответственности за любой ущерб, нанесенный вашему устройству. Используйте на свой риск.

**Nintendo Switch™** является товарным знаком Nintendo. Этот проект не связан с Nintendo.

---

<div align="center">

### 🌟 Если проект оказался полезным, поставьте звезду!

[![Star History Chart](https://api.star-history.com/svg?repos=Dimasick-git/Ryazhahand-Overlay&type=Date)](https://star-history.com/#Dimasick-git/Ryazhahand-Overlay&Date)

**Сделано с ❤️ для сообщества Nintendo Switch**

</div>
