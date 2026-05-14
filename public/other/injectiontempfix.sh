#!/bin/bash
# instead of making break lines, imma jst add comments atp

siliconappPath="/Applications/Roblox.app"
intelappPath="/Applications/RobloxPlayer.app"
noxdir="$HOME/Documents/Noxium"
execdir="$noxdir/Executable"

# sudo prompt
sudo -v

# roblox dies ok
killall Roblox 2>/dev/null
killall RobloxPlayer 2>/dev/null

# codesigning
echo "recodesigning..."

# roblox
if [[ -n "$siliconappPath" && -e "$siliconappPath" ]]; then
    sudo codesign --remove-signature "$siliconappPath" 2>/dev/null || true
    sudo codesign --force --deep --sign - "$siliconappPath"
fi

if [[ -n "$intelappPath" && -e "$intelappPath" ]]; then
    sudo codesign --remove-signature "$intelappPath" 2>/dev/null || true
    sudo codesign --force --deep --sign - "$intelappPath"
fi

# noxium
if [[ -n "$execdir" && -e "$execdir/noxiumapi" ]]; then
    sudo codesign --remove-signature "$execdir/noxiumapi" 2>/dev/null || true
    sudo codesign --force --deep --sign - "$execdir/noxiumapi"
fi

# bai bai
echo "ok open noxium and it should work now"
echo "made by @falrux"
