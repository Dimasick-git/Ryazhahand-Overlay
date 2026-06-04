# Пакеты Ryzhand

«Пакет» в Ryzhand — это папка `/switch/.packages/<имя>/` c файлом `package.ini`, описывающим набор команд. Запускается через главное меню → *Пакеты* → выбор пакета → выбор команды.

## Минимальный package.ini

```ini
[Привет, мир]
echo Hello, world!
```

После сохранения в `/switch/.packages/HelloWorld/package.ini` — пакет появляется в меню Ryzhand. Каждая секция `[…]` — это отдельная команда.

## Поддерживаемые директивы

Команды интерпретатора:

| Команда | Описание |
|---------|----------|
| `mkdir <path>` | Создать каталог. |
| `copy <src> <dst>` | Скопировать файл/папку. |
| `move <src> <dst>` | Переместить. |
| `delete <path>` | Удалить. |
| `download <url> <dst>` | Скачать по URL. |
| `unzip <archive> <dst>` | Распаковать zip. |
| `ini-set <file> <section> <key> <value>` | Изменить INI-конфиг. |
| `hex-set <file> <offset> <bytes>` | Hex-патч (offset в hex, bytes в hex без пробелов). |
| `mod-apply <ips/pchtxt> <target>` | Применить мод. |
| `boot-config <key> <value>` | Изменить параметр Atmosphere `boot2`. |
| `echo <text>` | Вывести сообщение в UI. |
| `exec <other-overlay.ovl>` | Запустить другой `.ovl`. |

Полный набор команд — см. примеры в `examples/`.

## Примеры

В этом репо лежат рабочие пакеты:

- `examples/Easy Installer/` — мастер установки сторонних оверлеев.
- `examples/OC Toolkit/` — пакет для управления разгоном (взаимодействует с RCU).
- `examples/Mod Master/` — IPS/pchtxt установка.
- `examples/Memory Config/` — конфигурация памяти.
- `examples/Broomstick/` — очистка SD от мусора.
- `examples/Host Guard/` — блокировка телеметрии.
- `examples/Cool Curves/` — кривые охлаждения (читает RCU).
- `examples/l4t_reboot/` — перезагрузка в Linux4Tegra.

## Где живут пользовательские пакеты

`/switch/.packages/<любое имя>/package.ini` — Ryzhand автоматически подхватывает все `package.ini` в этой папке (рекурсивно на 1 уровень).

## Локализация имён

Имена секций и `echo`-текст могут содержать русский — UI отрисует корректно.

## Безопасность

Команды выполняются с правами Atmosphere. Тщательно проверяйте чужие пакеты перед запуском — `delete` и `hex-set` могут необратимо повредить SD или системные файлы.

---
Автор: **Dimasick-git**
