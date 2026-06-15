#!/bin/bash

set -ouex pipefail

FEDORA_VERSION=$(rpm -E '%{fedora}')

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# Docker
rpm --import https://download.docker.com/linux/fedora/gpg
dnf5 config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo

dnf5 install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# VsCode from Microsoft
rpm --import https://packages.microsoft.com/keys/microsoft.asc

cat << 'EOF' > /etc/yum.repos.d/vscode.repo
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

dnf5 install -y code

# Terra Software
dnf5 config-manager setopt terra.enabled=1
dnf5 install -y zed
dnf5 config-manager setopt terra.enabled=0

## GNOME Extensions

# transparent-top-bar
GNOME_VERSION=$(rpm -q gnome-shell --queryformat '%{VERSION}' | cut -d. -f1)
EXT_UUID="transparent-top-bar@zhanghai.me"
curl -L "https://extensions.gnome.org/download-extension/${EXT_UUID}.shell-extension.zip?shell_version=${GNOME_VERSION}" \
    -o /tmp/${EXT_UUID}.zip
mkdir -p /usr/share/gnome-shell/extensions/${EXT_UUID}
unzip /tmp/${EXT_UUID}.zip -d /usr/share/gnome-shell/extensions/${EXT_UUID}
chmod -R a+rX /usr/share/gnome-shell/extensions/${EXT_UUID}
rm /tmp/${EXT_UUID}.zip

## System services
systemctl enable podman.socket
