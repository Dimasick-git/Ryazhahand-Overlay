# LED Control Sysmodule (Simple Version)

A lightweight sysmodule that controls the Switch Lite notification LED - **no libstratosphere required!**

## What's Different?

This version uses **only libnx** (which you already have), making it much easier to build on Windows without needing additional Atmosphere libraries.

## Features

- Full LED control (on/off, brightness, pulse)
- Configuration file system
- Hot reload support
- **Zero extra dependencies** - just libnx!

## Requirements

- Nintendo Switch Lite (or Hoag)
- Atmosphere CFW
- Firmware 8.1.1+
- devkitPro with libnx (that's it!)

## Building

```bash
# Windows (Command Prompt)
cd led-sysmodule-simple
make clean
make

# You'll get: led-control.nsp
```

That's it! No libstratosphere or libvapours needed!

## Installation

1. **Create directory structure on SD card:**
   ```
   sd:/atmosphere/contents/0100000000000LED/
   ├── flags/
   │   └── boot2.flag
   ├── exefs.nsp
   └── toolbox.json
   ```

2. **Copy files:**
   - `led-control.nsp` → `sd:/atmosphere/contents/0100000000000LED/exefs.nsp`
   - `toolbox.json` → `sd:/atmosphere/contents/0100000000000LED/toolbox.json`
   - Create empty file: `sd:/atmosphere/contents/0100000000000LED/flags/boot2.flag`

3. **Reboot**

## Configuration

Edit `sd:/config/led-control/config.txt`:

```ini
# LED Control Configuration
mode=solid
brightness=1.0
pulse_interval=1000
pulse_count=0
```

### Modes

- `mode=off` - LED off
- `mode=solid` - Constant brightness
- `mode=pulse` - Blinking/pulsing

### Settings

- `brightness` - 0.0 to 1.0 (0% to 100%)
- `pulse_interval` - milliseconds (e.g., 500 = half second)
- `pulse_count` - number of pulses (0 = infinite)

## Hot Reload

To apply changes without rebooting:

1. Edit `config.txt`
2. Create file: `sd:/config/led-control/reload`
3. Changes apply in ~500ms!

## Examples

**Dim constant light:**
```ini
mode=solid
brightness=0.3
```

**Fast pulse:**
```ini
mode=pulse
brightness=1.0
pulse_interval=250
pulse_count=0
```

**3 quick flashes:**
```ini
mode=pulse
brightness=1.0
pulse_interval=200
pulse_count=3
```

## Use with Tesla Overlay

This sysmodule works perfectly with the LED Control Overlay! The overlay provides a UI and this sysmodule does the actual LED control.

**Install both:**
1. This sysmodule (background control)
2. LED Control Overlay (UI in Tesla Menu)

## Troubleshooting

**Build errors:**
- Make sure devkitPro is installed
- Verify `DEVKITPRO` environment variable is set
- Only needs libnx - no other libraries!

**LED doesn't work:**
- Check firmware is 8.1.1+
- Only works on Switch Lite / Hoag
- Verify sysmodule is in correct directory
- Check atmosphere logs for errors

**Config not loading:**
- File must be exactly: `sd:/config/led-control/config.txt`
- Use proper line endings (Unix LF format)
- Check file permissions

## Technical Details

- **Dependencies**: libnx only
- **Service**: `led` (DeviceCode 0x35000065)
- **Title ID**: 0100000000000LED
- **Memory**: 256KB heap
- **CPU**: Core 3, Priority 44

## Why This Version?

The original version used libstratosphere which requires:
- libvapours
- Atmosphere development libraries
- Complex build setup

This version uses **only standard libnx** making it:
- ✅ Easy to build on Windows
- ✅ No extra dependencies
- ✅ Same functionality
- ✅ Smaller binary

## Credits

- Atmosphere team for CFW
- devkitPro for toolchain
- SwitchBrew for documentation

## License

Provided as-is for educational purposes.
