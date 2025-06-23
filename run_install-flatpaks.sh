#!/bin/bash

# This script iterates through a list of Flatpak application IDs.
# For each application, it checks if it is already installed from the 'flathub' remote.
# If it is, the script does nothing.
# If it's not installed from 'flathub' (meaning it's either not installed or
# installed from a different remote), it will install it from 'flathub'.

# TODO: Remove system-wide duplicates

FLATPAK_APP_IDS=(
    "com.bitwarden.desktop"
    "com.discordapp.Discord"
    "md.obsidian.Obsidian"
    "org.fedoraproject.MediaWriter"
    "org.mozilla.firefox"
    "runtime/org.freedesktop.Platform.ffmpeg-full/x86_64/24.08" # For Firefox
    "org.prismlauncher.PrismLauncher"
    "de.haeckerfelix.Fragments" # BitTorrent client
    "com.spotify.Client"
    "io.github.MakovWait.Godots"
    "org.gimp.GIMP"
    "org.inkscape.Inkscape"
    "org.musescore.MuseScore"
    "org.gnome.Boxes"
    "org.gnome.Extensions"
    "org.gnome.Loupe" # Image viewer
    "org.gnome.Snapshot" # Camera
    "org.gnome.TextEditor"
    "org.gnome.baobab" # Disk usage analyzer
    "org.gnome.Evince" # Document viewer
    "org.gnome.font-viewer"
    "org.gnome.NautilusPreviewer"
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
echo "--- Ensuring Flathub remote is added. ---"

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo "${FLATPAK_SCOPE_FLAG}"

echo "--- Checking which apps need to be (re)installed. ---"

INSTALL_APPS=()

# Loop through each application ID in the array
for APP_ID in "${FLATPAK_APP_IDS[@]}"; do
    if ! flatpak info "${APP_ID}" | grep -q "Origin: flathub"; then
        # App is not installed (from flathub)
        INSTALL_APPS+=("${APP_ID}")
    fi
done


if (( ${#INSTALL_APPS[@]} )); then
    echo "--- Installing apps. ---"
    echo "Installing ${INSTALL_APPS[*]}"
    # INSTALL_APPS not empty
    flatpak uninstall ${INSTALL_APPS[*]} -y
    flatpak install "${FLATPAK_SCOPE_FLAG}" flathub ${INSTALL_APPS[*]} -y
    if ! [ $? -eq 0 ]; then
        echo "ERROR: Failed to install apps from Flathub."
    fi
else
    echo "No apps to install."
fi


echo "--- Flatpak remote check and installation complete. ---"
