#!/usr/bin/env bash

export APPIMAGE_ROOT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

OLD_LIBRARY_SEARCH_PATH=$(ldconfig -v 2>/dev/null | grep -E '^/.*:' | cut -d: -f1 | tr '\n' ':' | sed 's/:$//')
export LD_LIBRARY_PATH=$APPIMAGE_ROOT/usr/lib:$OLD_LIBRARY_SEARCH_PATH:$LD_LIBRARY_PATH

export PATH=$APPIMAGE_ROOT/usr/bin:$PATH

$APPIMAGE_ROOT/opt/%{executable}/XIVLauncher.Core $@
