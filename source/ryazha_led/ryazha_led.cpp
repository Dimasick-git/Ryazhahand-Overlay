/*
 * Ryazha-LED -- единый модуль управления подсветкой Switch.
 * Часть проекта Ryazhahand-Overlay.
 *
 * Автор: Dimasick-git
 * Лицензия: GPL-2.0 (см. LICENSE)
 * Версия: 2.3.0
 *
 * Модуль хранит настройки подсветки в /config/ryazhahand/led.ini.
 * Применением на железе занимается фоновый sysmodule (sys-notif-LED
 * для обычной Switch и liteswitch-led для Switch Lite). Этот файл
 * только пишет конфиг и триггер перезагрузки -- никакого hidsys/i2c
 * напрямую отсюда не вызывается.
 */
#include "ryazha_led.hpp"

#include <cstdio>
#include <cstring>
#include <sys/stat.h>

namespace ryz::led {

namespace {

constexpr const char* CONFIG_DIR     = "sdmc:/config/ryazhahand";
constexpr const char* CONFIG_FILE    = "sdmc:/config/ryazhahand/led.ini";
constexpr const char* RELOAD_TRIGGER = "sdmc:/config/ryazhahand/led.reload";

bool g_liteCached = false;
bool g_liteDetected = false;

void ensureDir() {
    mkdir("sdmc:/config", 0777);
    mkdir(CONFIG_DIR, 0777);
}

void writeKV(FILE* f, const char* k, const char* v) {
    fprintf(f, "%s=%s\n", k, v);
}

const char* modeKey(Mode m) {
    switch (m) {
        case Mode::Off:     return "off";
        case Mode::Solid:   return "solid";
        case Mode::Pulse:   return "pulse";
        case Mode::Fade:    return "fade";
        case Mode::OnPress: return "onpress";
    }
    return "off";
}

Mode parseMode(const char* v) {
    if (!v) return Mode::Off;
    if (!strcmp(v, "solid"))   return Mode::Solid;
    if (!strcmp(v, "pulse"))   return Mode::Pulse;
    if (!strcmp(v, "fade"))    return Mode::Fade;
    if (!strcmp(v, "onpress")) return Mode::OnPress;
    return Mode::Off;
}

const char* targetKey(Target t) {
    switch (t) {
        case Target::Auto:       return "auto";
        case Target::HomeButton: return "home";
        case Target::JoyConL:    return "joyconL";
        case Target::JoyConR:    return "joyconR";
        case Target::LiteAll:    return "lite_all";
    }
    return "auto";
}

Target parseTarget(const char* v) {
    if (!v) return Target::Auto;
    if (!strcmp(v, "home"))     return Target::HomeButton;
    if (!strcmp(v, "joyconL"))  return Target::JoyConL;
    if (!strcmp(v, "joyconR"))  return Target::JoyConR;
    if (!strcmp(v, "lite_all")) return Target::LiteAll;
    return Target::Auto;
}

} // namespace

bool isLiteDetected() {
    if (g_liteCached) return g_liteDetected;

    SetSysProductModel model = SetSysProductModel_Invalid;
    Result rc = setsysGetProductModel(&model);
    if (R_SUCCEEDED(rc)) {
        // SetSysProductModel_Hoag соответствует Switch Lite.
        g_liteDetected = (model == SetSysProductModel_Hoag);
    } else {
        g_liteDetected = false;
    }
    g_liteCached = true;
    return g_liteDetected;
}

Settings load() {
    Settings s;
    FILE* f = fopen(CONFIG_FILE, "r");
    if (!f) return s;

    char line[256];
    while (fgets(line, sizeof line, f)) {
        if (line[0] == '#' || line[0] == '\n' || line[0] == ';') continue;
        char* eq = strchr(line, '=');
        if (!eq) continue;
        *eq = '\0';
        char* k = line;
        char* v = eq + 1;
        // strip newline
        size_t vl = strlen(v);
        while (vl && (v[vl-1] == '\n' || v[vl-1] == '\r')) { v[--vl] = '\0'; }

        if      (!strcmp(k, "mode"))            s.mode            = parseMode(v);
        else if (!strcmp(k, "target"))          s.target          = parseTarget(v);
        else if (!strcmp(k, "brightness"))      s.brightness      = (uint8_t)atoi(v);
        else if (!strcmp(k, "pulse_interval"))  s.pulseIntervalMs = (uint32_t)atoi(v);
        else if (!strcmp(k, "color_r"))         s.colorR          = (uint8_t)atoi(v);
        else if (!strcmp(k, "color_g"))         s.colorG          = (uint8_t)atoi(v);
        else if (!strcmp(k, "color_b"))         s.colorB          = (uint8_t)atoi(v);
    }
    fclose(f);

    if (s.brightness > 100) s.brightness = 100;
    return s;
}

namespace {
// liteswitch (Zach van Welzen, MIT) sysmodule -- путь и формат,
// которые он читает в loadConfig() из своего main.cpp. Сам по себе
// поддерживает три режима: off / solid / pulse. Brightness и
// другие наши поля он не использует, но писать их не вредно --
// формат строчно-key=value, неизвестные ключи он просто пропускает.
constexpr const char* LITE_CONFIG_DIR    = "sdmc:/config/led-control";
constexpr const char* LITE_CONFIG_FILE   = "sdmc:/config/led-control/config.txt";
constexpr const char* LITE_RELOAD_FILE   = "sdmc:/config/led-control/reload";

const char* liteModeKey(Mode m) {
    switch (m) {
        case Mode::Off:     return "off";
        case Mode::Solid:   return "solid";
        // У liteswitch нет fade -- маппим в pulse, ближайший по поведению.
        case Mode::Pulse:   return "pulse";
        case Mode::Fade:    return "pulse";
        case Mode::OnPress: return "off"; // pulse-per-press снизу обрабатывается отдельным триггером
    }
    return "off";
}

void writeLiteConfig(const Settings& s) {
    mkdir("sdmc:/config", 0777);
    mkdir(LITE_CONFIG_DIR, 0777);
    FILE* f = fopen(LITE_CONFIG_FILE, "w");
    if (!f) return;
    fprintf(f, "# /config/led-control/config.txt -- liteswitch sysmodule\n");
    fprintf(f, "# Пишется Ryzhand UI; держим в синхроне с led.ini.\n\n");
    fprintf(f, "mode=%s\n", liteModeKey(s.mode));
    // pulse_interval у нас в ms на полупериод, у них -- ms между миганиями.
    // Совпадает (см. их ledPulseLoop).
    fprintf(f, "pulse_interval=%u\n", (unsigned)s.pulseIntervalMs);
    // pulse_count = 0 в их формате значит бесконечно. UI не показывает
    // конкретное значение -- ставим 0 чтобы лампа пульсировала постоянно.
    fprintf(f, "pulse_count=0\n");
    // Brightness у liteswitch не используется, оставляем для будущей
    // совместимости (их config.txt parser игнорирует неизвестное).
    fprintf(f, "brightness=%.2f\n", (double)s.brightness / 100.0);
    fclose(f);

    // touch reload -- их sysmodule перечитает config без перезагрузки.
    FILE* r = fopen(LITE_RELOAD_FILE, "w");
    if (r) fclose(r);
}
} // namespace

bool save(const Settings& s) {
    ensureDir();
    FILE* f = fopen(CONFIG_FILE, "w");
    if (!f) return false;

    fprintf(f, "# Ryzhand LED settings -- управляется через UI оверлея\n");
    fprintf(f, "# Применяется фоновым sysmodule sys-notif-LED / liteswitch\n\n");

    writeKV(f, "mode",       modeKey(s.mode));
    writeKV(f, "target",     targetKey(s.target));
    fprintf(f, "brightness=%u\n",      (unsigned)s.brightness);
    fprintf(f, "pulse_interval=%u\n",  (unsigned)s.pulseIntervalMs);
    fprintf(f, "color_r=%u\n",         (unsigned)s.colorR);
    fprintf(f, "color_g=%u\n",         (unsigned)s.colorG);
    fprintf(f, "color_b=%u\n",         (unsigned)s.colorB);

    fclose(f);

    // touch reload trigger для sys-notif-LED (Xc987) -- он опрашивает
    // /config/ryazhahand/led.reload.
    FILE* t = fopen(RELOAD_TRIGGER, "w");
    if (t) fclose(t);

    // Дополнительно пишем настройки в формате liteswitch (Zach van Welzen)
    // чтобы один UI обслуживал и обычную Switch (через sys-notif-LED), и
    // Switch Lite (через liteswitch). На обычной Switch lite-config просто
    // не используется, на Lite -- наоборот, sys-notif-LED не активируется.
    writeLiteConfig(s);

    // Legacy ledCfgDir совместимость: старый UI homeLedToggleItem писал в
    // /config/ryazhahand-led/mode значения disabled / smart / battery. Этот
    // file читает наш собственный hidsys-loop (см. applyHomeLedPatternForKeys
    // и initialiseLedThread в main.cpp). При mode=Off в нашем enum должны
    // явно записать "disabled" сюда -- иначе lampa зажигается через
    // hidsys по событиям, даже если sys-notif-LED корректно потушил.
    mkdir("sdmc:/config/ryazhahand-led", 0777);
    FILE* lmf = fopen("sdmc:/config/ryazhahand-led/mode", "w");
    if (lmf) {
        if (s.mode == Mode::Off) {
            fputs("disabled", lmf);
        } else {
            fputs("smart", lmf);
        }
        fclose(lmf);
    }
    FILE* lrf = fopen("sdmc:/config/ryazhahand-led/reset", "w");
    if (lrf) fclose(lrf);

    return true;
}

const char* modeName(Mode m) {
    switch (m) {
        case Mode::Off:     return "Выкл";
        case Mode::Solid:   return "Постоянно";
        case Mode::Pulse:   return "Пульсация";
        case Mode::Fade:    return "Плавный";
        case Mode::OnPress: return "При нажатии";
    }
    return "Выкл";
}

const char* targetName(Target t) {
    switch (t) {
        case Target::Auto:       return "Авто";
        case Target::HomeButton: return "Кнопка HOME";
        case Target::JoyConL:    return "Joy-Con (левый)";
        case Target::JoyConR:    return "Joy-Con (правый)";
        case Target::LiteAll:    return "Lite — все";
    }
    return "Авто";
}

} // namespace ryz::led
