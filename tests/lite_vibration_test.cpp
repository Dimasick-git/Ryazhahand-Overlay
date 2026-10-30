#include "../source/lite_vibration_tone.hpp"
#include <cassert>
#include <cmath>
#include <vector>
#include <algorithm>

int main() {
    using ryz::lite_haptics::Tone;
    Tone tone;
    std::vector<std::int16_t> pcm(Tone::Rate * 2);
    tone.render(pcm.data(), Tone::Rate, 500);
    for (auto value : pcm) assert(value == 0); // idle never emits a tone
    for (unsigned clicks : {1u, 2u}) {
        tone.trigger(clicks);
        tone.render(pcm.data(), Tone::Rate, 500);
        unsigned audible = 0;
        for (unsigned i = 0; i < Tone::Rate; ++i) {
            const int left = pcm[i * 2], right = pcm[i * 2 + 1];
            assert(left == -right);
            assert(std::abs(left) <= 16384); // half-scale ceiling, no clipping
            const bool first = i < 1440;
            const bool second = clicks == 2 && i >= 6240 && i < 7680;
            if (!first && !second) assert(left == 0);
            if (left) ++audible;
        }
        assert(audible > (clicks == 2 ? 2500u : 1200u));
        // No repeated pulses after the event has ended.
        tone.render(pcm.data(), Tone::Rate, 500);
        for (auto value : pcm) assert(value == 0);
    }
    Tone muted;
    muted.trigger(2);
    muted.render(pcm.data(), Tone::Rate, 0);
    for (auto value : pcm) assert(value == 0);
    // Buffer boundaries must not change the waveform or event timing.
    Tone whole, split;
    whole.trigger(2); split.trigger(2);
    std::vector<std::int16_t> expected(9600 * 2), actual(9600 * 2);
    whole.render(expected.data(), 9600, 355);
    for (unsigned i = 0; i < 9600; i += 960) split.render(actual.data() + i * 2, 960, 355);
    assert(expected == actual);
    // Calibrator modes keep the half-scale ceiling at every available frequency.
    for (unsigned hz : {0u,1u,15u,20u,80u,220u,225u,300u,500u,1000u}) {
        for (unsigned phase : {0u,90u,180u,270u}) {
            Tone calibrated;
            calibrated.setCarrier(hz, phase);
            calibrated.trigger(1, 160);
            calibrated.render(pcm.data(), Tone::Rate, 500);
            unsigned rising = 0;
            for (unsigned i = 0; i < Tone::Rate; ++i) {
                const int left = pcm[2*i], right = pcm[2*i+1];
                assert(std::abs(left) <= 16384 && std::abs(right) <= 16384);
                if (phase == 0) assert(left == right);
                if (phase == 180) assert(left == -right);
                if (i >= 7680) assert(left == 0 && right == 0);
                if (i && pcm[2*(i-1)] <= 0 && left > 0) ++rising;
            }
            assert(std::abs(static_cast<double>(rising) - hz * .16) <= 1.1);
        }
    }
    // All phase modes must remain silent at zero Hz, including quadrature.
    for (unsigned hz : {0u,1u,15u,220u,1000u}) {
        for (unsigned phase : {0u,90u,180u,270u}) {
            for (unsigned strength : {0u,1u,500u,1000u,2000u}) {
                Tone edge;
                edge.setCarrier(hz, phase); edge.trigger(1,160);
                edge.render(pcm.data(), Tone::Rate, strength);
                for (auto sample : pcm) {
                    assert(sample != -32768);
                    if (strength <= 500) assert(std::abs(int(sample)) <= 16384);
                    if (hz == 0 || strength == 0) assert(sample == 0);
                }
            }
        }
    }
    Tone full, half, clamped;
    full.trigger(1,160); half.trigger(1,160); clamped.trigger(1,160);
    full.render(actual.data(),9600,1000); half.render(expected.data(),9600,500);
    int peak_full=0, peak_half=0;
    for (unsigned i=0;i<actual.size();++i) {
        peak_full=std::max(peak_full,std::abs(int(actual[i])));
        peak_half=std::max(peak_half,std::abs(int(expected[i])));
    }
    assert(peak_full > 32000 && peak_half > 16000 && peak_half <= 16384);
    clamped.render(expected.data(),9600,2000);
    assert(actual == expected);
    Tone invalid, defaults;
    invalid.setCarrier(1001, 17); defaults.setCarrier(220, 180);
    invalid.trigger(1); defaults.trigger(1);
    invalid.render(actual.data(), 9600, 500); defaults.render(expected.data(), 9600, 500);
    assert(actual == expected);
}

