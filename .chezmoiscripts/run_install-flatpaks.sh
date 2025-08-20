#!/bin/bash

# This script iterates through a list of Flatpak application IDs.
# For each application, it checks if it is already installed from the 'flathub' remote.
# If it is, the script does nothing.
# If it's not installed from 'flathub' (meaning it's either not installed or
# installed from a different remote), it will install it from 'flathub'.


FLATPAK_APP_IDS=(
    "com.bitwarden.desktop"
    "com.discordapp.Discord"
    "com.github.tchx84.Flatseal"
    "com.heroicgameslauncher.hgl" # Epic Games, GOG...
    "com.spotify.Client"
    "com.valvesoftware.Steam"
    "de.haeckerfelix.Fragments" # BitTorrent client
    "io.github.MakovWait.Godots"
    "md.obsidian.Obsidian"
    "org.audacityteam.Audacity"
    "org.fedoraproject.MediaWriter"
    "org.gimp.GIMP"
    "org.gnome.Boxes"
    "org.gnome.Decibels" # Audio player
    "org.gnome.Evince" # Document viewer
    "org.gnome.Extensions"
    "org.gnome.Loupe" # Image viewer
    "org.gnome.NautilusPreviewer"
    "org.gnome.Showtime" # Video player
    "org.gnome.SimpleScan" # Document scanner
    "org.gnome.Snapshot" # Camera
    "org.gnome.TextEditor"
    "org.gnome.baobab" # Disk usage analyzer
    "org.gnome.font-viewer"
    "org.inkscape.Inkscape"
    "org.libreoffice.LibreOffice"
    "org.mozilla.firefox"
    "runtime/org.freedesktop.Platform.ffmpeg-full/x86_64/24.08" # For Firefox
    "org.musescore.MuseScore"
    "org.prismlauncher.PrismLauncher" # Minecraft
)

# Set to 'true' if you want installations to be system-wide (requires sudo).
# Set to 'false' for user-specific installations (default Flatpak behavior).
# NOTE: If installing system-wide, run the script with 'sudo'.
INSTALL_SYSTEM_WIDE=false

# Determine the --user or --system flag based on INSTALL_SYSTEM_WIDE
FLATPAK_SCOPE_FLAG=""
if "$INSTALL_SYSTEM_WIDE"; then
    FLATPAK_SCOPE_FLAG="--system"
else
    FLATPAK_SCOPE_FLAG="--user"
fi

# Check if Flathub remote exists. Add it if not. When INSTALL_SYSTEM_WIDE is true, this requires sudo.
echo "Ensuring Flathub remote is added."

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo "${FLATPAK_SCOPE_FLAG}"

echo "Checking which Flatpak apps need to be (re)installed."

INSTALL_APPS=()

# Loop through each application ID in the array
for APP_ID in "${FLATPAK_APP_IDS[@]}"; do
    if ! flatpak info "${APP_ID}" | grep -q "Origin: flathub"; then
        # App is not installed (from flathub)
        INSTALL_APPS+=("${APP_ID}")
    fi
done


if (( ${#INSTALL_APPS[@]} )); then
    echo "Installing ${INSTALL_APPS[*]}"
    # INSTALL_APPS not empty
    flatpak uninstall ${INSTALL_APPS[*]} -y
    flatpak install "${FLATPAK_SCOPE_FLAG}" flathub ${INSTALL_APPS[*]} -y
    if ! [ $? -eq 0 ]; then
        echo "ERROR: Failed to install apps from Flathub."
    fi
else
    echo "No Flatpak apps to install."
fi
