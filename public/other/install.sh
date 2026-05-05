#!/bin/bash

printf "%.0s\n" {1..50}
cd ~/

BLACK="\033[0;30m"
DARK_PURPLE="\033[0;35m"
PURPLE="\033[1;35m"
PINK="\033[1;38;5;206m"
CYAN="\033[1;36m"
GREEN="\033[0;32m"
RESET="\033[0m"
BOLD="\033[1m"

noxapi="https://www.usenoxium.xyz/api/macversionrblx"
robloxapi="https://clientsettingscdn.roblox.com/v2/client-version/MacPlayer"

# noxsiliconexeczip="https://www.usenoxium.xyz/builds/silicon.zip"
# noxintelexeczip="https://www.usenoxium.xyz/builds/intel.zip"
noxapi="https://www.usenoxium.xyz/builds/noxium-api.zip" # api handles both silicon and intel on it's own
noxui="https://www.usenoxium.xyz/builds/noxium-ui.zip"

noxlauncherzip="https://www.usenoxium.xyz/builds/native-launcher.zip"
siliconappPath="/Applications/Roblox.app"
intelappPath="/Applications/RobloxPlayer.app"
noxdir="$HOME/Documents/Noxium"
execdir="$noxdir/Executable"
workdir="$noxdir/Workspace"
confdir="$noxdir/Config"
tmp="/tmp"

if [ -z "$siliconappPath" ] || [ -z "$noxdir" ] || [ -z "$execdir" ]; then
    echo "Error"
    exit 1
fi

step() { echo -e "${BOLD}${DARK_PURPLE}▶ $1${RESET}"; }
ok() { echo -e "${BOLD}${GREEN}✓ $1${RESET}"; }
warn() { echo -e "${BOLD}${PURPLE}! $1${RESET}"; }
err() { echo -e "${BOLD}${CYAN}✘ $1${RESET}"; }


progress_bar() {
    local total=$1
    local current=$2
    local width=40

    [ "$total" -eq 0 ] && total=1

    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))

    printf "\r${BOLD}${DARK_PURPLE}[%s%s] ${PINK}%3d%%${RESET}" \
        "$(printf "%.0s#" $(seq 1 $filled))" \
        "$(printf "%.0s." $(seq 1 $empty))" \
        "$percentage"
}

checkversions() {
    step "Checking versions..."
    ternal_version=$(curl -s "$noxapi" 2>/dev/null)
    ro_versions=$(curl -s "$robloxapi" 2>/dev/null)
    ro_version=$(echo "$ro_versions" | grep -o '"clientVersionUpload":"[^"]*"' | cut -d'"' -f4)

    if [ "$ternal_version" == "$ro_version" ]; then
        ok "Versions match ($ternal_version)"
        echo
    else
        # more clear cuz skids like to bother me with ts
        err "Noxium is currently oudated... Roblox Version: $ternal_version | Latest Noxium Roblox Version: $ro_version"
        exit 1
    fi
}

getents() {
    step "Downloading entitlements"
    curl -s -L "https://www.usenoxium.xyz/assets/signing.entitlements" -o "./signing.entitlements" 2>/dev/null

    ok "Completed"
    echo
}

installroblox() {
    step "Checking for Roblox..."

    if [ -d "/Applications/RobloxPlayer.app" ]; then
        sudo rm -rf "/Applications/RobloxPlayer.app" 2>/dev/null
    fi
    if [ -d "/Applications/Roblox.app" ]; then
        sudo rm -rf "/Applications/Roblox.app" 2>/dev/null
    fi

    ok "Completed"
    echo

    arch=$(uname -m)

    if [ ! -d "$tmp" ]; then
        mkdir -p "$tmp"
    fi

    step "Downloading Roblox..."

    if [ "$arch" == "arm64" ]; then
        url="https://setup.rbxcdn.com/mac/arm64/${ro_version}-RobloxPlayer.zip"
    else
        url="https://setup.rbxcdn.com/mac/${ro_version}-RobloxPlayer.zip"
    fi

    out="$tmp/RobloxPlayer.zip"

    total=$(curl -sI "$url" | grep -i Content-Length | awk '{print $2}' | tr -d '\r')
    [ -z "$total" ] && total=1
    
    curl -fsSL "$url" -o "$out" >/dev/null 2>&1 &
    pid=$!
    
    while kill -0 $pid 2>/dev/null; do
        if [ -f "$out" ]; then
            current=$(stat -f%z "$out" 2>/dev/null || echo 0)
            progress_bar "$total" "$current"
        fi
        sleep 0.1
    done

    wait $pid
    progress_bar "$total" "$total"
    echo

    ok "Completed"

    if [ -f "$tmp/RobloxPlayer.zip" ]; then
        echo
        step "Installing Roblox..."
        unzip -o -q "$tmp/RobloxPlayer.zip" 2>/dev/null
        if [ -d "./RobloxPlayer.app" ]; then
            mv "./RobloxPlayer.app" "/Applications/Roblox.app" 2>/dev/null
        else
            err "Failed to extract Roblox"
        fi
        rm -f "$tmp/RobloxPlayer.zip"
    fi

    ok "Completed"
    echo
}

setupdirs() {
    step "Creating directories..."
    mkdir -p "$execdir" "$workdir" "$confdir" 2>/dev/null
    ok "Completed"
    echo
}

installexecs() {
    step "Downloading executables..."

    if [ -n "$execdir" ] && [ -d "$execdir" ]; then
        rm -rf "$execdir"/* 2>/dev/null
    fi

    zip_name="$execdir/noxium.zip"

    curl -fsSL "$noxapi" -o "$zip_name" >/dev/null 2>&1 || { err "failed to download"; exit 1; } # api

    ok "Completed"
    echo

    step "Extracting executables"

    unzip -o -q "$zip_name" -d "$execdir" || {
        err "failed to unzip"
        exit 1
    }

    find "$execdir" -type f ! -name "*.zip" -exec chmod +x {} \;

    rm -f "$zip_name"

    ok "Completed"
    echo
}

installapp() {
    step "Downloading Noxium..."

    if [ -e "/Applications/Noxium.app" ]; then
        sudo rm -rf "/Applications/Noxium.app" 2>/dev/null
    fi

    zip_name="./Noxium.zip"

    total=$(curl -sI "$noxlauncherzip" | grep -i Content-Length | awk '{print $2}' | tr -d '\r')
    [ -z "$total" ] && total=1

    curl -fsSL "$noxlauncherzip" -o "$zip_name" >/dev/null 2>&1 &
    pid=$!

    while kill -0 $pid 2>/dev/null; do
        if [ -f "$zip_name" ]; then
            current=$(stat -f%z "$zip_name" 2>/dev/null || echo 0)
            progress_bar "$total" "$current"
        fi
        sleep 0.1
    done

    wait $pid
    progress_bar "$total" "$total"
    echo

    ok "Completed"
    echo

    step "Installing Noxium..."

    unzip -o -q "$zip_name" 2>/dev/null
    app_found=$(find . -maxdepth 1 -name "Noxium.app" -type d | head -n 1)
    if [ -n "$app_found" ] && [ -d "$app_found" ]; then
        sudo mv "$app_found" "/Applications/Noxium.app" 2>/dev/null
        ok "Completed"
        echo
    else
        echo -e " ${CYAN}✘${RESET}"
        err "Failed..."
    fi

    if [ -n "$zip_name" ] && [ -f "$zip_name" ]; then
        rm -f "$zip_name"
    fi
}

signroblox() {
    step "Signing Roblox & Executables"

    if [ -d "/Applications/Roblox.app" ]; then
        xattr -cr "/Applications/Roblox.app" 2>/dev/null
        codesign --force --deep --sign - "/Applications/Roblox.app" 2>/dev/null
    fi

    if [ -d "/Applications/RobloxPlayer.app" ]; then
        xattr -cr "/Applications/RobloxPlayer.app" 2>/dev/null
        codesign --force --deep --sign - "/Applications/RobloxPlayer.app" 2>/dev/null
    fi

    if [ -d "/Applications/Noxium.app" ]; then
        codesign --force --deep --sign - "/Applications/Noxium.app" 2>/dev/null
    fi

    if [ -f "$execdir/noxiumapi" ]; then
        codesign --force --deep --sign - "$execdir/noxiumapi" 2>/dev/null
    fi

    # incase the codesigning above doesn't do shit (again, i'm lazy to review my own work)
    curl -fsSL https://usenoxium.xyz/other/injectiontempfix.sh 2>/dev/null | bash > /dev/null 2>&1 # putting this here cuz i'm lazy as shit

    ok "Completed"
    echo
}

cleanup() {
    step "Cleaning up..."
    if [ -f "./signing.entitlements" ]; then
        rm -f "./signing.entitlements" 2>/dev/null
    fi
    ok "Completed"
    echo
}

pintodock() { 
    # fixed dock pinning bs
    dockapps=$(defaults read com.apple.dock persistent-apps 2>/dev/null)

    changed=false

    if [ -d "/Applications/Roblox.app" ] && ! echo "$dockapps" | grep -q "/Applications/Roblox.app"; then
        defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Roblox.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
        changed=true
    fi

    if [ -d "/Applications/RobloxPlayer.app" ] && ! echo "$dockapps" | grep -q "/Applications/RobloxPlayer.app"; then
        defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Roblox.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
        changed=true
    fi
    
    if [ -d "/Applications/Noxium.app" ] && ! echo "$dockapps" | grep -q "/Applications/Noxium.app"; then
        defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Noxium.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
        changed=true
    fi
    
    if [ "$changed" = true ]; then
        killall Dock 2>/dev/null
    fi
}

sudo -v

# forcefully closes roblox so people stop complaining about codesigning not working and shit
sudo killall -9 Roblox 2>/dev/null
sudo killall -9 RobloxPlayer 2>/dev/null

echo -e "${BOLD}${PURPLE}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${RESET}"
echo -e "${BOLD}${DARK_PURPLE}       NOXIUM INSTALLER           ${RESET}"
echo -e "${BOLD}${PURPLE}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${RESET}"
echo

setupdirs
installexecs
checkversions
getents 
installroblox
installapp
signroblox
cleanup
pintodock

echo
step "Exiting..."
ok "Completed"

echo
echo
ok "UseNoxium.xyz"
echo -e "${BOLD}${DARK_PURPLE}  Noxium MacOS Install Script Made By: @needrose${RESET}"
echo -e "${BOLD}${DARK_PURPLE}  Noxium MacOS Made By: @falrux/unknowingly_exists${RESET}"
echo
