#!/bin/bash
# Sets custom Nautilus folder icons. Icons are set by name rather than by path
# so they resolve through the active icon theme (Papirus, see dconf).

declare -A FOLDER_ICONS=(
    ["Android"]="folder-android"
    ["Development"]="folder-code"
    ["Games"]="folder-games"
    ["Google Drive"]="folder-gdrive"
)

echo "Setting custom folder icons."

for FOLDER in "${!FOLDER_ICONS[@]}"; do
    DIR="${HOME}/${FOLDER}"
    mkdir -p "${DIR}"
    gio set -t unset "${DIR}" metadata::custom-icon
    gio set "${DIR}" metadata::custom-icon-name "${FOLDER_ICONS[${FOLDER}]}"
done
