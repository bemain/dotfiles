#!/bin/bash
# Distrobox runs init hooks on every container start; the marker limits this
# setup to the first one. It is only written once setup succeeds.
set -euo pipefail

MARKER="/first_run"
[ -f "$MARKER" ] && exit 0

echo "Running first-time container setup."

# RPM Fusion
sudo dnf install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

# VS Code
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo tee /etc/yum.repos.d/vscode.repo > /dev/null <<'REPO'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
REPO

# chezmoi, so the cz alias also works inside the container
sudo dnf copr enable -y lihaohong/chezmoi

sudo dnf install -y code chezmoi

# Latest stable Flutter, extracted to /usr/local/flutter
FLUTTER_BASE_URL="https://storage.googleapis.com/flutter_infra_release/releases"
FLUTTER_ARCHIVE="$(curl -fsSL "$FLUTTER_BASE_URL/releases_linux.json" \
    | yq -r '.current_release.stable as $h | .releases[] | select(.hash == $h) | .archive')"
curl -fsSL "$FLUTTER_BASE_URL/$FLUTTER_ARCHIVE" | sudo tar -xJf - -C /usr/local/

sudo touch "$MARKER"
