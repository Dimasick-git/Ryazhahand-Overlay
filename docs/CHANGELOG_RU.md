# Changelog

Все заметные изменения отслеживаются здесь. Версионирование — [SemVer](https://semver.org/lang/ru/), формат — [Keep a Changelog](https://keepachangelog.com/ru/).

## [v2.3.0] — 2026-05-20

### Новое
- ** Модуль LED** (`source/led/`) — единая прослойка для управления подсветкой Switch и Switch Lite. Авто-детект модели через `setsysGetProductModel`. Режимы: Выкл / Постоянно / Пульсация / Плавный / **При нажатии**. Настройки сохраняются в `/config/ryazhahand/led.ini`. Физическое применение делает фоновый sysmodule (`sys-notif-LED` или `liteswitch-led`) — оверлей пишет конфиг и подаёт `led.reload` / `led.pulse` сигналы.
- **CI авто-сборка** — `.github/workflows/build.yml` на каждый push в `main` и PR; `.github/workflows/release.yml` на тег `v*.*.*` с публикацией `.ovl` и `.zip` в GitHub Releases.
- **Документация на русском** — README, `docs/UI_RU.md`, `docs/PACKAGES_RU.md`, `docs/INTEGRATION_RU.md`, этот файл.

### Изменено
- **Ребрендинг Ultrahand → Ryzhand/Ryazhahand**:
 - `ULTRAHAND` → `RYZHAND`
 - `Ultrahand` → `Ryzhand` (отображаемое имя)
 - `ultrahand` → `ryazhahand` (имена путей, идентификаторов конфига)
 - `Ultrahand-Overlay` → `Ryazhahand-Overlay` (имя репо)
 - `Ultrahand Overlay` → `Ryzhand Overlay`
- **Автор** — переехал с `ppkantorski` на `Dimasick-git`; репо переехал на `Dimanchikgshehsbshene/Ryazhahand-Overlay`.
- **Версия** — `APP_VERSION := 2.3.0` (был `2.2.5+`).
- **`.gitmodules`** — раньше указывал на `lib/libultrahand` → `ppkantorski/libultrahand`; библиотека `libryazhahand` теперь vendored (в подмодуль будет вынесена в v2.4.0, когда репо станет публичным).

### Исправлено
- **Сканер обновлений больше не блокирует загрузки пакетов**. Раньше он стартовал автоматически при открытии экрана пакетов и делал синхронные HTTPS-запросы к GitHub в UI-треде, занимая curl. Теперь:
 - `enableUpdateScanner` по умолчанию **выключен** (`false`). Включается явно в *Настройки → Сканер обновлений*.
 - При наличии конфига значение читается оттуда, но при отсутствии — `false`.
 - **Roadmap v2.4.0**: вынос сканера в отдельный `std::thread` с `atomic<UpdateScanState>`, 6-часовой кэш в `/config/ryazhahand/cache/updates.json`, жёсткие таймауты curl (8 c) — после этого можно будет включить по умолчанию обратно.

### Удалено
- Папки `Ultrahand-Overlay-main/`, `Atmosphere-CNX-master/`, `InfoNX-master/`, `libnx-*/`, `nx-ovlloader-master/`, `liteswitch-main/`, `sys-notif-LED-main/`, `home-led-project/`, `neo_sys-notif-LED-main/`, `kips/`, `payloads/`, `sounds/`, `themes/`, `tools/` — не были частью оверлея, копились как ссылки для изучения. ~2.5 ГБ.
- Mусорные файлы в корне: `Ryazhahand-Overlay 2.2.5.zip`, `Ryazhenka1.zip`, `Свечение.zip`, `MicroMem*.nro`, `exefs.nsp`, `ovlmenu.elf/.lst/.nacp/.ovl`, `.git.zip`, `*.lst`, `sdout.py`, `rename_all.sh`.
- Подмодуль `lib/libultrahand` и параллельная копия `lib/libryzhand/`.
- Локальный sysmodule `sysmodule/` (бинарники без исходников) — LED теперь работает через внешний sysmodule.

### Roadmap v2.4.0

- Полный рефакторинг сканера обновлений: отдельный поток, atomic-state, кэш, таймауты, ленивый запуск только по явному клику.
- Перенос `lib/libryazhahand` обратно в git submodule (после публикации `Dimanchikgshehsbshene/libryazhahand`).
- Интеграция UI настроек LED в *Прочее → Подсветка* — сейчас модуль скомпилирован но не подключён к UI; пока настройки правятся в `/config/ryazhahand/led.ini` вручную.
- Замена пикселарт-кота в экране обновлений на «руку кодера» (графика).
- Аватар автора (`.pics/author_avatar.png`) — пиксельный портрет `Dimasick-git`.

---

## История до v2.3.0

Предыдущая работа отслеживалась как `2.2.5+` — серия итеративных коммитов на собственном fork'е `Dimasick-git/Ryazhahand-Overlay`. Полная история коммитов: `git log --oneline`.
