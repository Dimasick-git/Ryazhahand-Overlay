#include <switch.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>
#include <sys/stat.h>

#define INNER_HEAP_SIZE 0x40000

#define LOG_FILE "./config/led-control/log.txt"

void WriteLog(char *buffer)
{
    FILE *log = fopen(LOG_FILE, "a");
    if(log != NULL)
    {
        fprintf(log, "%s\n", buffer);  
    }
    fclose(log);
}


extern "C" {
    u32 __nx_applet_type = AppletType_None;
    u32 __nx_fs_num_sessions = 1;
    
    void __libnx_initheap(void) {
        static u8 inner_heap[INNER_HEAP_SIZE];
        extern void* fake_heap_start;
        extern void* fake_heap_end;
        
        fake_heap_start = inner_heap;
        fake_heap_end = inner_heap + sizeof(inner_heap);
    }
    
    void __appInit(void) {
        Result rc;
        
        rc = setsysInitialize();
        if (R_SUCCEEDED(rc)) {
            SetSysFirmwareVersion fw;
            rc = setsysGetFirmwareVersion(&fw);
            if (R_SUCCEEDED(rc))
                hosversionSet(MAKEHOSVERSION(fw.major, fw.minor, fw.micro));
            setsysExit();
        }

        rc = smInitialize();
        if (R_FAILED(rc))
            diagAbortWithResult(rc);
        
        rc = fsInitialize();
        if (R_FAILED(rc))
            diagAbortWithResult(rc);
        
        rc = fsdevMountSdmc();
        if (R_FAILED(rc))
            diagAbortWithResult(MAKERESULT(Module_Libnx, LibnxError_InitFail_FS));

    }
    
    void __appExit(void) {
        fsdevUnmountAll();
        fsExit();
        smExit();
    }
}

// ─── GPIO LED control ────────────────────────────────────────────────────────
// DeviceCode 0x35000065 = GPIO pad Y,5 = Notification LED PWM (CLK 32K OUT)
// Used with OpenMode ReadWrite (3)

static Service g_gpioSrv  = {};
static Service g_gpioPad  = {};
static bool    g_gpioInit = false;

// OpenMode
typedef enum {
    GpioOpenMode_None      = 0,
    GpioOpenMode_Read      = 1,
    GpioOpenMode_Write     = 2,
    GpioOpenMode_ReadWrite = 3,
} GpioOpenMode;

// Settings
enum LEDMode { LED_OFF, LED_SOLID, LED_PULSE };

struct LEDSettings {
    LEDMode mode;
    u64     pulseInterval; // ms per half-cycle (on time = off time)
    u32     pulseCount;    // 0 = infinite
};

static LEDSettings g_settings = {
    .mode          = LED_OFF,
    .pulseInterval = 1000,
    .pulseCount    = 0,
};

Result gpioInitialize() {
    if (g_gpioInit) return 0;

    Result rc = smGetService(&g_gpioSrv, "gpio");
    if (R_FAILED(rc)) return rc;

    // OpenSession (cmd 7) with DeviceCode 0x35000065 and OpenMode ReadWrite (3)
    const struct {
        u32 device_code;
        u32 open_mode;
    } in = { 0x35000065, GpioOpenMode_ReadWrite };

    rc = serviceDispatchIn(&g_gpioSrv, 7, in,
        .out_num_objects = 1,
        .out_objects     = &g_gpioPad
    );

    if (R_SUCCEEDED(rc)) {
        g_gpioInit = true;

        // Set direction to output (cmd 19 = SetDirectionOutput with GpioValue_Low)
        const struct { u32 value; } dir_in = { GpioValue_Low };
        serviceDispatchIn(&g_gpioPad, 19, dir_in);
    } else {
        serviceClose(&g_gpioSrv);
    }

    return rc;
}

void gpioExit() {
    if (g_gpioInit) {
        serviceClose(&g_gpioPad);
        serviceClose(&g_gpioSrv);
        g_gpioInit = false;
    }
}

// SetValue (cmd 8)
Result gpioSetValue(GpioValue value) {
    if (!g_gpioInit) return MAKERESULT(Module_Libnx, LibnxError_NotInitialized);
    const struct { u32 value; } in = { (u32)value };
    return serviceDispatchIn(&g_gpioPad, 8, in);
}

// ─── LED helpers ─────────────────────────────────────────────────────────────

void ledOn()  { gpioSetValue(GpioValue_High); }
void ledOff() { gpioSetValue(GpioValue_Low);  }

bool checkReload() {
    FILE* f = fopen("sdmc:/config/led-control/reload", "r");
    if (!f) return false;
    fclose(f);
    remove("sdmc:/config/led-control/reload");
    return true;
}

void ledPulseLoop() {
    u32 pulsesLeft = g_settings.pulseCount;
    u64 halfPeriod = g_settings.pulseInterval * 1000000ULL; // ms -> ns

    while (true) {
        // ON
        ledOn();
        svcSleepThread(halfPeriod);

        // OFF
        ledOff();
        svcSleepThread(halfPeriod);

        if (pulsesLeft > 0) {
            if (--pulsesLeft == 0) {
                g_settings.mode = LED_OFF;
                return;
            }
        }

        // Check for config reload mid-pulse
        if (checkReload()) return;
    }
}

// ─── Config ──────────────────────────────────────────────────────────────────

void writeDefaultConfig() {
    mkdir("sdmc:/config",             0777);
    mkdir("sdmc:/config/led-control", 0777);
    FILE* f = fopen("sdmc:/config/led-control/config.txt", "w");
    if (!f) return;
    fprintf(f,
        "# LED Control Sysmodule\n"
        "# mode: off | solid | pulse\n"
        "# pulse_interval: milliseconds per half-cycle\n"
        "# pulse_count: 0 = infinite\n\n"
        "mode=pulse\n"
        "pulse_interval=1000\n"
        "pulse_count=0\n"
    );
    fclose(f);
}

void loadConfig() {
    FILE* f = fopen("sdmc:/config/led-control/config.txt", "r");
    if (!f) { writeDefaultConfig(); return; }

    char line[256];
    while (fgets(line, sizeof(line), f)) {
        if (line[0] == '#' || line[0] == '\n') continue;
        char* eq = strchr(line, '=');
        if (!eq) continue;
        *eq = '\0';
        char* key = line;
        char* val = eq + 1;
        char* nl  = strchr(val, '\n');
        if (nl) *nl = '\0';

        if (strcmp(key, "mode") == 0) {
            if      (strcmp(val, "solid") == 0) g_settings.mode = LED_SOLID;
            else if (strcmp(val, "pulse") == 0) g_settings.mode = LED_PULSE;
            else                                g_settings.mode = LED_OFF;
        }
        else if (strcmp(key, "pulse_interval") == 0) g_settings.pulseInterval = (u64)atoi(val);
        else if (strcmp(key, "pulse_count")    == 0) g_settings.pulseCount    = (u32)atoi(val);
    }
    fclose(f);

    if (g_settings.pulseInterval < 50) g_settings.pulseInterval = 50;
}

void applyConfig() {
    switch (g_settings.mode) {
        case LED_OFF:   ledOff();        break;
        case LED_SOLID: ledOn();         break;
        case LED_PULSE: ledPulseLoop();  break; // blocks until reload
    }
}

// ─── Main ────────────────────────────────────────────────────────────────────

int main(int argc, char* argv[]) {
    Result rc = gpioInitialize();
    if (R_FAILED(rc)) return 0; // GPIO not available, exit gracefully

    loadConfig();
    applyConfig();

    while (true) {
        if (checkReload()) {
            loadConfig();
            applyConfig();
        }
        svcSleepThread(500000000ULL); // 500ms
    }

    gpioExit();
    return 0;
}