#include "lite_vibration.hpp"
#include "lite_vibration_tone.hpp"
#include <cstdio>

namespace ryz::lite_haptics {
namespace {
// All calls run on Ryzhand's EXISTING haptics thread. There is no extra
// worker, event queue, shutdown flag or thread join in this implementation.
bool model_checked = false;
bool is_lite = false;
bool ready = false;
bool audio_ref = false;
bool event_open = false;
bool in_flight = false;
constexpr Settings settings{}; // User-selected 225 Hz, full scale, antiphase.
Service manager{}, stream{};
Event released{};
AudioOutBuffer buffer{};
alignas(0x1000) std::int16_t pcm[16384]; // enough for the 160 ms double click

// Failures only: a write per menu click would hit the SD card on every move.
void trace(const char* stage, Result rc) {
    if (FILE* file = std::fopen("sdmc:/config/ryazhahand/lite-haptics.log", "a")) {
        std::fprintf(file, "%s: %08X\n", stage, rc);
        std::fclose(file);
    }
}
#define LITE_TRY(expr) do { const Result rc = (expr); if (R_FAILED(rc)) return rc; } while (0)

void closeOutput() {
    if (serviceIsActive(&stream)) serviceDispatch(&stream, 2);
    serviceClose(&stream);
    if (event_open) { eventClose(&released); event_open = false; }
    serviceClose(&manager);
    if (audio_ref) { audoutExit(); audio_ref = false; }
    ready = false;
    in_flight = false;
}

Result openOutput() {
    LITE_TRY(audoutInitialize());
    audio_ref = true;
    LITE_TRY(serviceClone(audoutGetServiceSession(), &manager));
    char name[0x100]{}, actual[0x100]{};
    const struct { u32 rate, channels; u64 aruid; } in{48000, 0x20000, 0};
    struct { u32 rate, channels, format, state; } out{};
    LITE_TRY(serviceDispatchInOut(&manager, 3, in, out,
        .buffer_attrs = {SfBufferAttr_HipcAutoSelect | SfBufferAttr_In,
                         SfBufferAttr_HipcAutoSelect | SfBufferAttr_Out},
        .buffers = {{name, sizeof(name)}, {actual, sizeof(actual)}},
        .in_send_pid = true,
        .in_num_handles = 1,
        .in_handles = {CUR_PROCESS_HANDLE},
        .out_num_objects = 1,
        .out_objects = &stream));
    serviceClose(&manager);
    if (out.rate != 48000 || out.channels != 2 || out.format != PcmFormat_Int16)
        return MAKERESULT(Module_Libnx, LibnxError_BadInput);
    Handle handle = INVALID_HANDLE;
    LITE_TRY(serviceDispatch(&stream, 4,
        .out_handle_attrs = {SfOutHandleAttr_HipcCopy}, .out_handles = &handle));
    eventLoadRemote(&released, handle, true);
    event_open = true;
    // Keep the haptic stream at unity gain, separate from RyazhTune's
    // per-game process-volume control. The shared output gain still applies.
    const float volume = 1.f;
    LITE_TRY(serviceDispatchIn(&stream, 12, volume));
    LITE_TRY(serviceDispatch(&stream, 1));
    ready = true;
    return 0;
}

Result drain() {
    if (!in_flight) return 0;
    const u64 start = armGetSystemTick();
    while (true) {
        AudioOutBuffer* done = nullptr;
        u32 count = 0;
        LITE_TRY(serviceDispatchOut(&stream, 8, count,
            .buffer_attrs = {SfBufferAttr_HipcAutoSelect | SfBufferAttr_Out},
            .buffers = {{&done, sizeof(done)}}));
        if (count) {
            if (done != &buffer) return MAKERESULT(Module_Libnx, LibnxError_BadInput);
            in_flight = false;
            return 0;
        }
        const u64 elapsed = armTicksToNs(armGetSystemTick() - start);
        if (elapsed >= 250'000'000ULL) return KERNELRESULT(TimedOut);
        LITE_TRY(eventWait(&released, 250'000'000ULL - elapsed));
    }
}

Result play(u32 clicks) {
    LITE_TRY(drain()); // Never overwrite PCM while audio service owns it.
    Tone tone;
    const auto current = GetSettings();
    tone.setCarrier(current.frequency_hz, current.phase_degrees);
    tone.trigger(clicks);
    const unsigned frames = clicks == 2 ? 7680 : 1440;
    tone.render(pcm, frames, current.strength);
    buffer = {};
    buffer.buffer = pcm;
    buffer.buffer_size = sizeof(pcm);
    buffer.data_size = frames * 2 * sizeof(std::int16_t);
    const u64 tag = reinterpret_cast<u64>(&buffer);
    LITE_TRY(serviceDispatchIn(&stream, 7, tag,
        .buffer_attrs = {SfBufferAttr_HipcAutoSelect | SfBufferAttr_In},
        .buffers = {{&buffer, sizeof(buffer)}}));
    in_flight = true;
    return 0;
}
}

void Initialize() {
    if (!model_checked) {
        SetSysProductModel model = SetSysProductModel_Invalid;
        const Result rc = setsysGetProductModel(&model);
        if (R_FAILED(rc)) { trace("model query", rc); return; }
        model_checked = true;
        is_lite = model == SetSysProductModel_Hoag;
    }
    // Initialization stays lazy until an actual enabled feedback event.
}
void Exit() {
    closeOutput();
}
void Trigger(u32 clicks) {
    if (!is_lite || (clicks != 1 && clicks != 2)) return;
    if (!ready) {
        const Result rc = openOutput();
        if (R_FAILED(rc)) { trace("open failed", rc); closeOutput(); return; }
    }
    const Result rc = play(clicks);
    if (R_FAILED(rc)) { trace("pulse failed", rc); closeOutput(); }
}
Settings GetSettings() { return settings; }
}
