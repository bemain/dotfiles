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
sudo rpmkeys --import -y https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=download.vscodium.com\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg\nmetadata_expire=1h\n" | sudo tee -a /etc/yum.repos.d/vscodium.repo

# Add Chezmoi Copr repository
sudo dnf copr enable -y lihaohong/chezmoi

# Install packages
sudo dnf check-update -y
sudo dnf install -y codium chezmoi

# Install Flutter
sudo mkdir /usr/local/flutter
wget -q -O - "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.32.4-stable.tar.xz" | sudo tar -xJf - -C /usr/local/


exit 0

