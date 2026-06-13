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

# Zed editor (from terra repo)
curl -fsSL "https://repos.fyralabs.com/terra${FEDORA_VERSION}/key.asc" | tee "/etc/pki/rpm-gpg/RPM-GPG-KEY-terra${FEDORA_VERSION}"
dnf5 config-manager addrepo --from-repofile="https://repos.fyralabs.com/terra${FEDORA_VERSION}/terra.repo"
dnf5 install -y zed
dnf5 config-manager setopt terra.enabled=0
# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
