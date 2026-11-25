#!/bin/bash
# Distrobox runs init hooks on every container start; the marker limits this
# setup to the first one. It is only written once setup succeeds.
set -euo pipefail

# Distrobox rewrites this profile on every start. Its host-spawn calls read the
# terminal's stdin, so input waiting for a new shell is lost, such as the
# commands Herdr types to reconnect its panes.
PROFILE="/etc/profile.d/distrobox_profile.sh"
if [ -f "$PROFILE" ]; then
    sudo sed -i '/\/dev\/null)"$/! s/"\$(host-spawn \(.*\))"$/"$(host-spawn \1 <\/dev\/null)"/' "$PROFILE"
fi

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

# OpenRig CLI. It lives in the shared home (~/.local), so it usually survives a
# rebuild; reinstall the same version when it is missing or no longer runs on
# this container's Node. Hooks run as root, so install as the home's owner.
OWNER="$(stat -c %U "$HOME")"
as_owner() {
    if [ "$(id -un)" = "$OWNER" ]; then
        env PATH="$HOME/.local/bin:$PATH" "$@"
    else
        sudo -u "$OWNER" env HOME="$HOME" PATH="$HOME/.local/bin:$PATH" "$@"
    fi
}
OPENRIG_PKG="$HOME/.local/lib/node_modules/@openrig/cli/package.json"
if ! as_owner rig --version >/dev/null 2>&1; then
    OPENRIG_VERSION="$(yq -r '.version // "latest"' "$OPENRIG_PKG" 2>/dev/null || echo latest)"
    as_owner npm install -g --prefix "$HOME/.local" "@openrig/cli@$OPENRIG_VERSION"
fi
as_owner rig --version

sudo touch "$MARKER"
