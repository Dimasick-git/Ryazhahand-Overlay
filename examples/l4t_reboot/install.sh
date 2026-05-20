#!/bin/bash
################################################################################
# File: install.sh
# Author: Dimasick-git
# Description:
#   This script is part of the Ryzhand-Overlay project and is responsible for
#   installing and configuring the necessary components of the project. It
#   automates the setup process for the Ryzhand-Overlay on your system.
#
#   Key Features:
#   - Installation of required dependencies.
#   - Configuration of system settings.
#   - Setup of the Ryzhand-Overlay project.
#
#   Note: Please refer to the project documentation and README.md for detailed
#   information on how to use and configure this script within the Ryzhand-Overlay.
#
#   For the latest updates and contributions, visit the project's GitHub repository.
#   (GitHub Repository: https://github.com/Dimanchikgshehsbshene/Ryzhand-Overlay)
#
# Copyright (c) 2023 Dimasick-git
# All rights reserved.
################################################################################

# Set the path to your Python script
script_path="/usr/local/bin/l4t_reboot.py"

# Move the script to the desired location
mv "$(dirname "$0")/l4t_reboot.py" "$script_path"
chmod +x "$script_path"

# Create the .desktop file
echo "[Desktop Entry]
Type=Application
Exec=/usr/bin/python3 $script_path
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=L4T-Reboot
Name=L4T-Reboot
Comment[en_US]=Run L4T-Reboot on startup
Comment=Run L4T-Reboot on startup
Terminal=false" > ~/.config/autostart/L4T-Reboot.desktop

# Make the .desktop file executable
chmod +x ~/.config/autostart/L4T-Reboot.desktop
