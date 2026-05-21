# LED Control Overlay

A Tesla overlay that controls the LED Control sysmodule by writing to its configuration file.

## How It Works

This overlay provides a simple UI to control the LED sysmodule without needing special permissions:

1. User selects settings in the overlay
2. Overlay writes to `sd:/config/led-control/config.txt`
3. Overlay creates `sd:/config/led-control/reload` trigger file
4. Sysmodule detects the trigger and reloads configuration
5. LED updates instantly!

## Requirements

- **LED Control Sysmodule** must be installed and running
- Tesla Menu (nx-ovlloader)
- Atmosphere CFW

## Installation

1. Build the overlay:
   ```bash
   make clean
   make
   ```

2. Copy to SD card:
   ```
   sd:/switch/.overlays/led-control-overlay.ovl
   ```

3. Open Tesla Menu (L + DPad Down + Right Stick Click)

## Features

### Quick Presets
- **Turn OFF** - Instantly turn off the LED
- **ON - Full Brightness** - 100% brightness solid
- **ON - Dim (30%)** - Low brightness solid
- **Pulse - Slow (1s)** - Breathing effect, 1 second interval
- **Pulse - Fast (250ms)** - Quick pulsing
- **Pulse - 3 Times** - Flash 3 times then stop

### Custom Settings
- **Mode Selection**: Off, Solid, Pulse
- **Brightness**: 25%, 50%, 75%, 100%
- **Pulse Interval**: 250ms, 500ms, 1000ms, 2000ms
- **Pulse Count**: Set in config file (0 = infinite)

### Current Settings Display
Shows what the LED is currently doing

## Usage

1. Open Tesla Menu: **L + DPad Down + Right Stick Click**
2. Navigate to "LED Control"
3. Select a preset or go to Custom Settings
4. Settings apply immediately!

## Building

```bash
# Ensure devkitPro and libtesla are installed
make clean
make
```

Output: `led-control-overlay.ovl`

## File Structure

The overlay manages these files:
- `sd:/config/led-control/config.txt` - LED settings
- `sd:/config/led-control/reload` - Trigger file for hot reload

## Troubleshooting

### Overlay doesn't show settings
- Make sure the sysmodule is installed and running
- Check that `sd:/config/led-control/` exists

### Settings don't apply
- Verify sysmodule is running (check atmosphere logs)
- Manually check `sd:/config/led-control/config.txt` was created
- Try rebooting to restart the sysmodule

### LED doesn't change
- Sysmodule might not be installed
- Your Switch might not support the LED service (needs 8.1.1+ and Switch Lite/Hoag)

## Integration

This overlay is designed to work alongside the LED Control sysmodule. Both must be installed:

**Sysmodule**: Runs in background, has permissions to control LED
**Overlay**: Provides UI, writes config file, triggers reload

## Credits

- Tesla Menu by WerWolv
- libtesla
- devkitPro toolchain

## License

Provided as-is for educational purposes.
