#!/usr/bin/env bash

set -euo pipefail

APP_NAME="XIVLauncher"
APPIMAGE_NAME="$APP_NAME-x86_64.AppImage"
APPIMAGE_URL="https://github.com/spiteful-fox/xivlauncher-appimage/releases/latest/download/$APPIMAGE_NAME"
APPIMAGE_PATH="/tmp/$APPIMAGE_NAME"

if ! flatpak list --app | grep -q "it.mijorus.gearlever"; then
    echo "Gear Lever flatpak not found. Installing system-wide..."
    sudo flatpak install --system -y flathub it.mijorus.gearlever
else
    echo "Gear Lever flatpak is already installed."
fi

if flatpak run it.mijorus.gearlever --list-installed | grep -q "^$APP_NAME$"; then
    echo "$APP_NAME is already integrated with Gear Lever. Skipping integration."
else
    echo "Downloading $APPIMAGE_NAME..."

    curl -L -o "$APPIMAGE_PATH" "$APPIMAGE_URL"
    chmod +x "$APPIMAGE_PATH"

    echo "Integrating $APPIMAGE_NAME with Gear Lever..."
    yes | flatpak run it.mijorus.gearlever --integrate "$APPIMAGE_PATH"
fi
