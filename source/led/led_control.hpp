#pragma once

// Управление подсветкой Switch / Switch Lite из Ryzhand Overlay.
//
// Архитектура:
//   - Overlay только пишет настройки в /config/ryazhahand/led.ini.
//   - Применением занимается фоновый sysmodule (sys-notif-LED или
//     liteswitch-led, устанавливается отдельно). Этот файл — оверлейная сторона.
//
// Этот модуль не зависит от tsl::; вызывается из main.cpp.

#include <switch.h>
#include <cstdint>
#include <string>

namespace ryz::led {

enum class Mode : uint8_t {
    Off     = 0,
    Solid   = 1,
    Pulse   = 2,
    Fade    = 3,
    OnPress = 4,   // короткий импульс при нажатии кнопки
};

enum class Target : uint8_t {
    Auto       = 0, // авто-детект: на Lite — все LED, иначе Joy-Con
    HomeButton = 1, // только LED кнопки HOME (есть только на док-станции/Lite)
    JoyConL    = 2,
    JoyConR    = 3,
    LiteAll    = 4, // Switch Lite — единственный сегмент LED
};

struct Settings {
    Mode     mode          = Mode::Off;
    Target   target        = Target::Auto;
    uint8_t  brightness    = 80;     // 0..100 %
    uint32_t pulseIntervalMs = 500;
    // RGB используется только для Joy-Con LED (если поддерживается).
    uint8_t  colorR = 0xFF;
    uint8_t  colorG = 0xFF;
    uint8_t  colorB = 0xFF;
};

// Авто-детект Switch Lite (через setsysGetT API).
bool isLiteDetected();

// Загрузить настройки с диска. Если файл не существует — заполняет defaults.
Settings load();

// Сохранить настройки на диск и подать сигнал reload sysmodule
// (touch /config/ryazhahand/led.reload).
bool save(const Settings& s);

// Применить мгновенный импульс OnPress (короткое свечение).
// Безопасно вызывать из UI-loop при нажатии кнопки.
void onButtonPress(uint64_t keysDown);

// Строковые названия режимов и целей для UI.
const char* modeName(Mode m);
const char* targetName(Target t);

} // namespace ryz::led
