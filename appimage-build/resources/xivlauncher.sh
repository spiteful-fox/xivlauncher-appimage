#!/usr/bin/env bash

export APPIMAGE_ROOT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

export LD_LIBRARY_PATH=$APPIMAGE_ROOT/usr/lib:$LD_LIBRARY_PATH
export PATH=$APPIMAGE_ROOT/usr/bin:$APPIMAGE_ROOT/usr/lib:$PATH

$APPIMAGE_ROOT/opt/%{executable}/XIVLauncher.Core $@
