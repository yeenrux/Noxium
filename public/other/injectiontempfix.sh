#!/bin/bash

# instead of making break lines, imma jst add comments atp

siliconappPath="/Applications/Roblox.app"
intelappPath="/Applications/RobloxPlayer.app"
noxdir="$HOME/Documents/Noxium"
execdir="$noxdir/Executable"

# dtc arch
arch=$(uname -m)

if [[ "$arch" == "arm64" ]]; then
    ROBLOX_APP="$siliconappPath"
else
    ROBLOX_APP="$intelappPath"
fi

# sudo prompt
sudo -v

# roblox dies ok
killall Roblox 2>/dev/null
killall RobloxPlayer 2>/dev/null

# codesigning
echo "recodesigning..."
# roblox
sudo codesign --remove-signature "$ROBLOX_APP" 2>/dev/null || true
sudo codesign --force --deep --sign - "$ROBLOX_APP"
# noxium
sudo codesign --remove-signature "$execdir/noxiumapi" 2>/dev/null || true
sudo codesign --force --deep --sign - "$execdir/noxiumapi"

# bai bai
echo "ok open noxium and it should work now"
echo "made by @falrux"
