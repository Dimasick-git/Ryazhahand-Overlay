# liteswitch
Switch lite homebrew app that finally gives the home button light functionality

## Features
### Light Modes
- Solid - light stays lit constantly
- Pulse - light pulses based on the configuration
- Off - light is turned off

## Usage
Before installing the overlay you will need an overlay manager like [Tesla-Menu](https://github.com/WerWolv/Tesla-Menu) or [Ultrahand-Overlay](https://github.com/ppkantorski/Ultrahand-Overlay) along with [nx-ovloader](https://github.com/WerWolv/nx-ovlloader)

After installing the prerequisites put the contents of the latest release of liteswitch into the root of your switch.

## Compilation
### Using Docker
#### Build command
```bash
docker compose run --rm build
```
#### Clean command
```bash
docker compose run --rm clean
```
### Manually

To compuile the code on your own you will need the following prerequisites:
- [devkitpro](https://github.com/devkitPro/installer/releases)
- [libtesla](https://github.com/WerWolv/libtesla)

#### Build Command
```bash
make all
```
#### Clean Command
```bash
make clean
```