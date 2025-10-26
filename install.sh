#!/usr/bin/env bash

set -euo pipefail

GEARLEVER_ID="it.mijorus.gearlever"
FLATPAK_REPO_NAME="flathub"
FLATPAK_REPO_URL="https://flathub.org/repo/flathub.flatpakrepo"

# Check if flatpak is installed
if ! command -v flatpak &> /dev/null; then
    echo "Error: flatpak is not installed on your system."
    echo "Please install flatpak by visiting: https://flatpak.org/setup/"
    exit 1
fi

APP_NAME=""
if [ "${1-''}" = "rb" ]; then
    APP_NAME="XIVLauncher-RB"
else
    APP_NAME="XIVLauncher"
fi

APPIMAGE_NAME="$APP_NAME-x86_64.AppImage"
APPIMAGE_URL="https://github.com/spiteful-fox/xivlauncher-appimage/releases/latest/download/$APPIMAGE_NAME"
APPIMAGE_PATH="$(mktemp -d)/$APPIMAGE_NAME"

# Check if Gear Lever is already installed (system or user level)
if flatpak list --app --system --user | grep -q "$GEARLEVER_ID"; then
    echo "Gear Lever flatpak is already installed."
else
    echo "Gear Lever flatpak not found. Installing..."

    # Try system-level installation first (the way Bazzite does things)
    if [ "$(id -u)" -ne 0 ]; then  # Not running as root
        echo "Attempting system-wide installation with sudo..."
        if sudo -n true 2>/dev/null || sudo -v; then  # Check if we can get sudo or prompt for it
            # Add flathub repository to system if not present
            if ! flatpak remote-list --system | grep -q "$FLATPAK_REPO_NAME"; then
                echo "Adding $FLATPAK_REPO_NAME repository to system..."
                sudo flatpak remote-add --system --if-not-exists $FLATPAK_REPO_NAME $FLATPAK_REPO_URL
            fi
            echo "Installing Gear Lever at system level..."
            sudo flatpak install --system -y $FLATPAK_REPO_NAME $GEARLEVER_ID
        else
            echo "Sudo permissions not granted. Installing Gear Lever at user level..."
            # Add flathub repository to user if not present
            if ! flatpak remote-list --user | grep -q "$FLATPAK_REPO_NAME"; then
                echo "Adding $FLATPAK_REPO_NAME repository to user..."
                flatpak remote-add --user --if-not-exists $FLATPAK_REPO_NAME $FLATPAK_REPO_URL
            fi
            echo "Installing Gear Lever at user level..."
            flatpak install --user -y $FLATPAK_REPO_NAME $GEARLEVER_ID
        fi
    else  # Running as root, install directly to system
        # Add flathub repository to system if not present
        if ! flatpak remote-list --system | grep -q "$FLATPAK_REPO_NAME"; then
            echo "Adding $FLATPAK_REPO_NAME repository to system..."
            flatpak remote-add --system --if-not-exists $FLATPAK_REPO_NAME $FLATPAK_REPO_URL
        fi
        echo "Installing Gear Lever at system level (running as root)..."
        flatpak install --system -y $FLATPAK_REPO_NAME $GEARLEVER_ID
    fi
fi

if [ ! -z "$(flatpak run $GEARLEVER_ID --list-installed | grep "^$APP_NAME\s")" ]; then
    echo "$APP_NAME is already integrated with Gear Lever. Skipping integration."
else
    echo "Downloading $APPIMAGE_NAME..."

    curl -L -o "$APPIMAGE_PATH" "$APPIMAGE_URL"
    chmod +x "$APPIMAGE_PATH"

    echo "Integrating $APPIMAGE_NAME with Gear Lever..."
    flatpak run $GEARLEVER_ID "$APPIMAGE_PATH"
fi
