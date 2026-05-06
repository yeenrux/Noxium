#!/bin/bash

noxdir="$HOME/Documents/Noxium"

sudo -v

sudo killall -9 Noxium 2>/dev/null
sudo killall -9 noxium 2>/dev/null # i forgot
sudo killall -9 Roblox 2>/dev/null
sudo killall -9 RobloxPlayer 2>/dev/null

if [ -d "/Applications/NoxiumLauncher.app" ]; then
    sudo rm -rf "/Applications/Noxium.app"
fi

if [ -d "/Applications/Noxium.app" ]; then
    sudo rm -rf "/Applications/Noxium.app"
fi

if [ -d "$noxdir" ]; then
    sudo rm -rf "$noxdir"
fi

echo "uninstalled ok bai"
