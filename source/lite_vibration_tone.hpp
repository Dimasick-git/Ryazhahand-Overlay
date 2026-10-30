#pragma once

#include <cmath>
#include <cstddef>
#include <cstdint>

namespace ryz::lite_haptics {
// Event-driven acoustic feedback, not a repeating test tone.
// Strength 0..1000 maps to 0..100% PCM; 500 preserves the old 50% level.
// No connection to game vibration commands.
class Tone {
public:
    static constexpr unsigned Rate = 48000;
    void setCarrier(unsigned hz, unsigned phase_degrees = 180) {
        frequency = hz <= 1000 ? hz : 220;
        right_phase = phase_degrees == 0 || phase_degrees == 90 || phase_degrees == 270 ? phase_degrees : 180;
    }
    void trigger(unsigned clicks, unsigned duration_ms = 30) {
        position = 0;
        phase = 0;
        pulse_count = clicks == 2 ? 2 : 1;
        duration_ms = duration_ms >= 8 && duration_ms <= 160 ? duration_ms : 30;
        pulse_frames = Rate * duration_ms / 1000;
    }
    void render(std::int16_t* output, std::size_t frames, unsigned strength) {
        if (strength > 1000) strength = 1000;
        const float target = strength / 1000.f;
        for (std::size_t i = 0; i < frames; ++i) {
            // Smooth live strength changes over ~10 ms, including mute.
            constexpr float step = 0.5f / 480.f;
            if (gain < target) gain = std::fmin(target, gain + step);
            if (gain > target) gain = std::fmax(target, gain - step);
            float envelope = 0;
            // Match Ryzhand's 30 ms click / 100 ms gap / 30 ms click.
            const unsigned Pulse = pulse_frames;
            constexpr unsigned Gap = Rate / 10;
            const unsigned local = position >= Pulse + Gap ? position - Pulse - Gap : position;
            if (frequency != 0 && pulse_count && local < Pulse &&
                (position < Pulse || pulse_count == 2)) {
                const auto edge = local < Pulse / 2 ? local : Pulse - local;
                const float fade = std::fmin(1.f, edge / 240.f);
                envelope = 0.5f - 0.5f * std::cos(3.14159265358979323846f * fade);
            }
            const auto sample = envelope == 0 ? std::int16_t{0} :
                static_cast<std::int16_t>(std::lround(32767.f * gain * envelope *
                    std::sin(phase * (6.2831853071795864769 / Rate))));
            output[2 * i] = sample;
            if (right_phase == 180) output[2 * i + 1] = -sample;
            else if (right_phase == 0) output[2 * i + 1] = sample;
            else output[2 * i + 1] = envelope == 0 ? std::int16_t{0} :
                static_cast<std::int16_t>(std::lround(32767.f * gain * envelope *
                    std::sin(((phase + Rate * right_phase / 360) % Rate) *
                        (6.2831853071795864769 / Rate))));
            phase = (phase + frequency) % Rate;
            if (pulse_count) {
                ++position;
                const unsigned end = pulse_count == 2 ? 2 * Pulse + Gap : Pulse;
                if (position >= end) pulse_count = 0;
            }
        }
    }
private:
    unsigned position = 0;
    unsigned phase = 0;
    float gain = 0;
    unsigned pulse_count = 0;
    unsigned pulse_frames = Rate * 30 / 1000;
    unsigned frequency = 220;
    unsigned right_phase = 180;
};
}

