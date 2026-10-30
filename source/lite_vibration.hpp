#pragma once
#include <switch.h>

namespace ryz::lite_haptics {
struct Settings { unsigned frequency_hz = 225; unsigned phase_degrees = 180; unsigned strength = 1000; };
void Initialize();
void Exit();
void Trigger(u32 clicks);
Settings GetSettings();
}
