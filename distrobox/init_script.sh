#!/bin/bash

echo "Running init script \n"

FILE_TO_CHECK="/first_run"

# Check if the first run file exists
if [ -f "$FILE_TO_CHECK" ]; then
    echo "The marker file '$FILE_TO_CHECK' is present."
    echo "This indicates that the script has been run before."
    echo "To simulate a 'first run', delete '$FILE_TO_CHECK'."
    exit 0
fi


# This is the first run
echo "The marker file '$FILE_TO_CHECK' is NOT present."
echo "This appears to be the first run of the script."

touch "$FILE_TO_CHECK"

# Check if the file was created successfully
if [ -f "$FILE_TO_CHECK" ]; then
    echo "Successfully created marker file: '$FILE_TO_CHECK'."
else
    echo "Error: Could not create marker file '$FILE_TO_CHECK'."
    exit 1 # Exit with an error code
fi


# Add RPM Fusion repository
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Add VSCodium repository
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null

# Add Chezmoi Copr repository
sudo dnf copr enable -y lihaohong/chezmoi

# Install packages
sudo dnf check-update -y
sudo dnf install -y code chezmoi

# Install Flutter
sudo mkdir /usr/local/flutter
wget -q -O - "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.32.4-stable.tar.xz" | sudo tar -xJf - -C /usr/local/


exit 0

