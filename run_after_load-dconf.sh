#!/bin/bash
# Load dconf from the dump file

# Replace the placeholder with the actual ID of the distrobox 'fedora' for the Ptyxis profile
FEDORA_CONTAINER_ID="$(podman ps -a --filter name=fedora --format '{{.ID}}' --no-trunc)"
USER_CONF=$(sed -e "s/my-fedora-distrobox/${FEDORA_CONTAINER_ID}/" ~/.local/share/chezmoi/dot_config/dconf/user.conf)

echo "Loading dconf."

printf "$USER_CONF" | dconf load /
