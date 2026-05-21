/*
 * Ryazha-LED -- единый sysmodule управления HOME/notification LED
 * на любых моделях Switch (Erista/Mariko, OLED, Lite).
 *
 * Title ID: 0100000000000ED1
 *
 * Автор сборки: Dimasick-git
 * Лицензия:    MIT (см. LICENSE рядом)
 *
 * Объединяет в одном бинаре две раннее независимых вещи:
 *   - GPIO PWM control для Switch Lite (на основе Zach van Welzen
 *     liteswitch, MIT, https://github.com/zachvanwelzen/liteswitch)
 *   - hidsysSetNotificationLedPattern для Joy-Con notification LED
 *     на обычной Switch / OLED (на основе Xc987 sys-notif-LED, MIT,
 *     https://github.com/Xc987/sys-notif-LED)
 *
 * Auto-detect железа через setsysGetProductModel:
 *   - SetSysProductModel_Hoag -> Switch Lite -> GPIO путь
 *   - всё остальное (Nx/Iowa/Aula) -> hidsys путь
 *
 * Конфиг единый для всех платформ:
 *   sdmc:/config/ryazhahand/led.ini   (пишется Ryazha-LED UI оверлея)
 *   sdmc:/config/ryazhahand/led.reload (touch-файл, hot-reload)
 *
 * Формат led.ini (упрощённо -- мы читаем только то что умеем):
 *   mode           = off | solid | pulse | fade | onpress
 *   brightness     = 0..100 (%)
 *   pulse_interval = ms на полупериод
 */

#include <switch.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>
#include <sys/stat.h>

// 0x40000 = 256 KB heap. Раньше брали 0x80000 (512 KB) -- осталось от
// исходного liteswitch шаблона, реально sysmodule только читает INI и
// дёргает hidsys / GPIO, никакого heavy-allocation тут нет. Экономим
// 256 KB на каждой включённой консоли. Если когда-то заведётся OOM --
// поднимем обратно, но при таких объёмах работы это маловероятно.
#define INNER_HEAP_SIZE 0x40000
#define MAX_PADS 8

extern "C" {
    u32 __nx_applet_type = AppletType_None;
    u32 __nx_fs_num_sessions = 1;

    void __libnx_initheap(void) {
        static u8 inner_heap[INNER_HEAP_SIZE];
        extern void* fake_heap_start;
        extern void* fake_heap_end;
        fake_heap_start = inner_heap;
        fake_heap_end   = inner_heap + sizeof(inner_heap);
    }

    void __appInit(void) {
        Result rc;

        rc = setsysInitialize();
        if (R_SUCCEEDED(rc)) {
            SetSysFirmwareVersion fw;
            rc = setsysGetFirmwareVersion(&fw);
            if (R_SUCCEEDED(rc))
                hosversionSet(MAKEHOSVERSION(fw.major, fw.minor, fw.micro));
            // setsys нужен и main() для setsysGetProductModel -- не закрываем
        }

        rc = smInitialize();
        if (R_FAILED(rc)) diagAbortWithResult(rc);

        rc = fsInitialize();
        if (R_FAILED(rc)) diagAbortWithResult(rc);

        rc = fsdevMountSdmc();
        if (R_FAILED(rc)) diagAbortWithResult(MAKERESULT(Module_Libnx, LibnxError_InitFail_FS));

        // hidsysInitialize нужен только на обычной Switch, но запускаем
        // безусловно -- на Lite ему просто никто не отдаст управление,
        // плюс инициализация дешёвая.
        hidsysInitialize();
    }

    void __appExit(void) {
        hidsysExit();
        fsdevUnmountAll();
        fsExit();
        smExit();
        setsysExit();
    }
}

// ─── GPIO LED control (Switch Lite, PWM на пин Y,5) ─────────────────────────
// DeviceCode 0x35000065 = GPIO pad Y,5 = Notification LED PWM.
//
// libnx уже несёт enum GpioValue (Low/High) и публичные gpioInitialize/Exit
// для сервиса. Но нам нужен **сырой** доступ к device-code 0x35000065 через
// serviceDispatchIn (cmd 7 / 8 / 19), которого высокоуровневый libnx API
// не покрывает. Поэтому делаем свой набор функций с префиксом liteGpio*,
// чтобы не конфликтовать с libnx-овскими символами.

namespace {

enum LiteGpioOpenMode : u32 {
    LiteGpioOpenMode_None      = 0,
    LiteGpioOpenMode_Read      = 1,
    LiteGpioOpenMode_Write     = 2,
    LiteGpioOpenMode_ReadWrite = 3,
};

Service g_gpioSrv  = {};
Service g_gpioPad  = {};
bool    g_gpioInit = false;

Result liteGpioOpen() {
    if (g_gpioInit) return 0;

    Result rc = smGetService(&g_gpioSrv, "gpio");
    if (R_FAILED(rc)) return rc;

    // OpenSession (cmd 7) -- DeviceCode + OpenMode -> session к конкретному GPIO.
    const struct { u32 device_code; u32 open_mode; } in =
        { 0x35000065, LiteGpioOpenMode_ReadWrite };

    rc = serviceDispatchIn(&g_gpioSrv, 7, in,
        .out_num_objects = 1,
        .out_objects     = &g_gpioPad);

    if (R_SUCCEEDED(rc)) {
        g_gpioInit = true;
        // SetDirectionOutput (cmd 19) с начальным значением Low.
        const struct { u32 value; } dir_in = { (u32)GpioValue_Low };
        serviceDispatchIn(&g_gpioPad, 19, dir_in);
    } else {
        serviceClose(&g_gpioSrv);
    }
    return rc;
}

void liteGpioClose() {
    if (g_gpioInit) {
        serviceClose(&g_gpioPad);
        serviceClose(&g_gpioSrv);
        g_gpioInit = false;
    }
}

Result liteGpioSetValue(GpioValue value) {
    if (!g_gpioInit) return MAKERESULT(Module_Libnx, LibnxError_NotInitialized);
    const struct { u32 value; } in = { (u32)value };
    return serviceDispatchIn(&g_gpioPad, 8, in);
}

void gpioLedOn()  { liteGpioSetValue(GpioValue_High); }
void gpioLedOff() { liteGpioSetValue(GpioValue_Low);  }

} // namespace

// ─── hidsys LED control (обычная Switch / OLED, Joy-Con notification LED) ──
// Базовый паттерн -- solid или blink. Полный набор upstream-овских
// "battery"/"charge" режимов сюда не тянул: их у нас всё равно нет в
// led.ini, и UI про них не знает.

static HidsysUniquePadId  g_pads[MAX_PADS];
static int                g_numPads = 0;
static HidsysNotificationLedPattern g_pattern;

static void buildSolidPattern(u8 intensity4) {
    memset(&g_pattern, 0, sizeof(g_pattern));
    g_pattern.baseMiniCycleDuration = 0x8;
    g_pattern.totalMiniCycles       = 0x1;
    g_pattern.startIntensity        = intensity4 & 0xF;
    g_pattern.miniCycles[0].ledIntensity      = intensity4 & 0xF;
    g_pattern.miniCycles[0].transitionSteps   = 0x0;
    g_pattern.miniCycles[0].finalStepDuration = 0xF;
}

static void buildBlinkPattern(u8 intensity4, u8 baseDur) {
    memset(&g_pattern, 0, sizeof(g_pattern));
    g_pattern.baseMiniCycleDuration = baseDur ? baseDur : 0x4;
    g_pattern.totalMiniCycles       = 0x2;
    g_pattern.startIntensity        = intensity4 & 0xF;
    g_pattern.miniCycles[0].ledIntensity      = intensity4 & 0xF;
    g_pattern.miniCycles[0].transitionSteps   = 0xF;
    g_pattern.miniCycles[0].finalStepDuration = 0xF;
    g_pattern.miniCycles[1].ledIntensity      = 0x0;
    g_pattern.miniCycles[1].transitionSteps   = 0xF;
    g_pattern.miniCycles[1].finalStepDuration = 0xF;
}

static void buildOffPattern() {
    memset(&g_pattern, 0, sizeof(g_pattern));
}

static void scanForControllers() {
    static const HidNpadIdType ids[] = {
        HidNpadIdType_No1, HidNpadIdType_No2,
        HidNpadIdType_No3, HidNpadIdType_No4,
        HidNpadIdType_Handheld,
    };
    for (size_t i = 0; i < sizeof(ids) / sizeof(ids[0]); i++) {
        HidsysUniquePadId pads[2] = {};
        s32 total = 0;
        if (R_FAILED(hidsysGetUniquePadsFromNpad(ids[i], pads, 2, &total)))
            continue;
        for (s32 j = 0; j < total && g_numPads < MAX_PADS; j++) {
            // Уже есть -- skip.
            bool seen = false;
            for (int k = 0; k < g_numPads; k++) {
                if (g_pads[k].id == pads[j].id) { seen = true; break; }
            }
            if (!seen) g_pads[g_numPads++] = pads[j];
        }
    }
}

static void applyHidsysPattern() {
    for (int i = 0; i < g_numPads; i++) {
        Result rc = hidsysSetNotificationLedPattern(&g_pattern, g_pads[i]);
        if (R_FAILED(rc)) {
            // Отключённый pad -- убираем из списка.
            for (int k = i; k < g_numPads - 1; k++) g_pads[k] = g_pads[k + 1];
            g_numPads--;
            i--;
        }
    }
}

// ─── Config (наш формат) ────────────────────────────────────────────────────

enum LedMode : u8 { LED_OFF = 0, LED_SOLID = 1, LED_PULSE = 2, LED_FADE = 3 };

struct Settings {
    LedMode mode;
    u8      brightness;     // 0..100
    u32     pulseIntervalMs;
};

static Settings g_cfg = { LED_OFF, 80, 500 };

static bool checkReload() {
    FILE* f = fopen("sdmc:/config/ryazhahand/led.reload", "r");
    if (!f) return false;
    fclose(f);
    remove("sdmc:/config/ryazhahand/led.reload");
    return true;
}

static LedMode parseMode(const char* v) {
    if (!strcmp(v, "solid"))   return LED_SOLID;
    if (!strcmp(v, "pulse"))   return LED_PULSE;
    if (!strcmp(v, "fade"))    return LED_FADE;
    return LED_OFF;
}

static void loadConfig() {
    g_cfg = { LED_OFF, 80, 500 };
    FILE* f = fopen("sdmc:/config/ryazhahand/led.ini", "r");
    if (!f) {
        mkdir("sdmc:/config",            0777);
        mkdir("sdmc:/config/ryazhahand", 0777);
        return;
    }
    char line[256];
    while (fgets(line, sizeof line, f)) {
        if (line[0] == '#' || line[0] == ';' || line[0] == '\n') continue;
        char* eq = strchr(line, '=');
        if (!eq) continue;
        *eq = '\0';
        char* k = line;
        char* v = eq + 1;
        char* nl = strchr(v, '\n'); if (nl) *nl = '\0';
        char* cr = strchr(v, '\r'); if (cr) *cr = '\0';

        if (!strcmp(k, "mode"))                 g_cfg.mode            = parseMode(v);
        else if (!strcmp(k, "brightness"))      g_cfg.brightness      = (u8)atoi(v);
        else if (!strcmp(k, "pulse_interval"))  g_cfg.pulseIntervalMs = (u32)atoi(v);
    }
    fclose(f);
    if (g_cfg.brightness > 100) g_cfg.brightness = 100;
    if (g_cfg.pulseIntervalMs < 50) g_cfg.pulseIntervalMs = 50;
}

// ─── Платформа-зависимое применение ─────────────────────────────────────────

static bool g_isLite = false;

static void detectHardware() {
    SetSysProductModel model = SetSysProductModel_Invalid;
    if (R_SUCCEEDED(setsysGetProductModel(&model))) {
        g_isLite = (model == SetSysProductModel_Hoag);
    }
}

static void applyLite() {
    if (!g_gpioInit) return;
    switch (g_cfg.mode) {
        case LED_OFF:   gpioLedOff(); break;
        case LED_SOLID: gpioLedOn();  break;
        case LED_PULSE:
        case LED_FADE: {
            // Цикл "вкл/выкл" с pulseInterval на полупериод. Прерываемся
            // на reload-файле, чтобы UI мог поменять режим без перезагрузки.
            const u64 halfNs = (u64)g_cfg.pulseIntervalMs * 1000000ULL;
            while (true) {
                gpioLedOn();
                svcSleepThread(halfNs);
                if (checkReload()) return;
                gpioLedOff();
                svcSleepThread(halfNs);
                if (checkReload()) return;
            }
        }
    }
}

static void applyRegular() {
    // 0..100 % -> 0..15 (4-битная градация hidsys)
    const u8 intensity4 = (u8)((g_cfg.brightness * 15 + 50) / 100);
    switch (g_cfg.mode) {
        case LED_OFF:                       buildOffPattern();                 break;
        case LED_SOLID:                     buildSolidPattern(intensity4);     break;
        case LED_PULSE:                     buildBlinkPattern(intensity4, 0x4); break;
        case LED_FADE:                      buildBlinkPattern(intensity4, 0x8); break;
    }
    scanForControllers();
    applyHidsysPattern();
}

static void applyConfig() {
    if (g_isLite) applyLite();
    else          applyRegular();
}

// ─── Main loop ──────────────────────────────────────────────────────────────

int main(int /*argc*/, char** /*argv*/) {
    detectHardware();

    if (g_isLite) {
        Result rc = liteGpioOpen();
        if (R_FAILED(rc)) {
            // GPIO недоступен (странно для Lite, но не валим консоль) --
            // просто спим и ждём reload, на случай если железо вернётся.
            while (true) { svcSleepThread(2000000000ULL); }
        }
    }

    loadConfig();
    applyConfig();

    while (true) {
        if (checkReload()) {
            loadConfig();
            applyConfig();
        }
        // На обычной Switch периодически переапплаим pattern: если
        // подключили новый Joy-Con после старта -- LED получит его
        // через scanForControllers внутри applyRegular.
        if (!g_isLite) applyRegular();
        svcSleepThread(500000000ULL);  // 500 ms
    }

    if (g_isLite) liteGpioClose();
    return 0;
}
