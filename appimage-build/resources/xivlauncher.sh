#!/usr/bin/env bash

OLD_LIBRARY_SEARCH_PATH=$(ldconfig -v 2>/dev/null | grep -E '^/.*:' | cut -d: -f1 | tr '\n' ':' | sed 's/:$//')
export LD_LIBRARY_PATH=$APPDIR/usr/lib:$OLD_LIBRARY_SEARCH_PATH:$LD_LIBRARY_PATH

export PATH=$APPDIR/usr/bin:$PATH

$APPDIR/opt/%{executable}/XIVLauncher.Core $@
