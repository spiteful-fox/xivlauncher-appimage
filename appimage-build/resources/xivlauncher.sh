#!/usr/bin/env bash

OLD_LIBRARY_SEARCH_PATH=$(ldconfig -v 2>/dev/null | grep -E '^/.*:' | cut -d: -f1 | tr '\n' ':' | sed 's/:$//')
export LD_LIBRARY_PATH=$APPDIR/usr/lib:$OLD_LIBRARY_SEARCH_PATH:$LD_LIBRARY_PATH

export PATH=$APPDIR/usr/bin:$PATH

if [ ! -z "$WAYLAND_DISPLAY" ] && ( [ "$XDG_CURRENT_DESKTOP" == "GNOME" ] || [ "$XDG_CURRENT_DESKTOP" == "ubuntu:GNOME" ] ); then
    export SDL_VIDEO_DRIVER="${SDL_VIDEO_DRIVER:-x11}"
fi

$APPDIR/opt/%{executable}/XIVLauncher.Core $@
