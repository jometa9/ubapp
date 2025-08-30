#!/bin/bash

set -e

APP_NAME="UnplugBlock.app"
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_PATH="$CURRENT_DIR/$APP_NAME"
INSTALL_PATH="/Applications/$APP_NAME"

echo "UnplugBlock Installer"
echo "====================="
echo ""

if [ ! -d "$APP_PATH" ]; then
    echo "Error: $APP_NAME not found in current directory"
    echo "   Make sure this script is in the same directory as $APP_NAME"
    exit 1
fi

echo "Installing UnplugBlock..."

if [ -d "$INSTALL_PATH" ]; then
    echo "UnplugBlock is already installed in Applications"
    read -p "Do you want to overwrite the existing installation? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled"
        exit 1
    fi
    
    echo "Removing previous installation..."
    sudo rm -rf "$INSTALL_PATH"
fi

echo "Copying application to /Applications..."
sudo cp -R "$APP_PATH" "$INSTALL_PATH"

echo "Configuring permissions..."
sudo chown -R root:wheel "$INSTALL_PATH"
sudo chmod -R 755 "$INSTALL_PATH"

echo "Installation completed!"
echo ""
echo "IMPORTANT - Permission Setup:"
echo "============================="
echo ""
echo "UnplugBlock needs special permissions to work:"
echo ""
echo "1. AUTOMATION PERMISSIONS:"
echo "   - Go to: System Preferences > Privacy & Security > Automation"
echo "   - Find 'UnplugBlock' and enable permissions for 'System Events'"
echo ""
echo "2. FUNCTIONALITY:"
echo "   - A icon will appear in the menu bar"
echo "   - When you disconnect charger: LOGS OUT SESSION IMMEDIATELY"
echo "   - SAVE YOUR WORK before disconnecting!"
echo ""
echo "3. AUTO-START (Optional):"
echo "   - Go to: System Preferences > Users & Groups > Login Items"
echo "   - Add UnplugBlock to start automatically"
echo ""

read -p "Do you want to run UnplugBlock now to configure permissions? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo "Running UnplugBlock..."
    echo "NOTE: First time will ask for automation permissions."
    echo "      This is normal and required for it to work!"
    open "$INSTALL_PATH"
    
    echo ""
    echo "REMEMBER:"
    echo "   - Look for the icon in the menu bar"
    echo "   - Accept all permissions requested by macOS"
    echo "   - Save your work before disconnecting the charger!"
fi

echo ""
echo "Installation completed successfully!"
echo "If you have issues, check documentation or contact support."
