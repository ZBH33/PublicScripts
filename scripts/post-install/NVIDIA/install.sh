#!/usr/bin/env bash


# ============================================================================
# NVIDIA GPU ENABLEMENT SCRIPT
# Ubuntu Server 22.04 / 24.04
# ============================================================================
# - Installs recommended NVIDIA driver
# - Optionally disables nouveau
# - Verifies installation
# ============================================================================


set -euo pipefail


# --- FUNCTIONS ---------------------------------------------------------------
log() {
    echo "[INFO] $*"
}


error() {
    echo "[ERROR] $*" >&2
    exit 1
}


require_root() {
    if [ "${EUID:-$(id -u)}" -ne 0 ]; then
        error "This script must be run as root (use sudo)."
    fi
}


# --- PRECHECKS ---------------------------------------------------------------
require_root


if ! lspci | grep -qi nvidia; then
    error "No NVIDIA GPU detected via lspci. Aborting."
fi


log "NVIDIA GPU detected. Proceeding."


# --- SYSTEM UPDATE -----------------------------------------------------------
log "Updating system packages"
apt update && apt upgrade -y


# --- DEPENDENCIES ------------------------------------------------------------
log "Installing build dependencies"
apt install -y build-essential dkms linux-headers-$(uname -r)


# --- DISABLE NOUVEAU ----------------------------------------------------------
log "Disabling nouveau driver"
cat >/etc/modprobe.d/blacklist-nouveau.conf <<'EOF'
blacklist nouveau
options nouveau modeset=0
EOF


update-initramfs -u


# --- DRIVER DETECTION ---------------------------------------------------------
log "Detecting recommended NVIDIA driver"
DRIVER=$(ubuntu-drivers devices | awk '/recommended/ {print $3; exit}')


if [ -z "$DRIVER" ]; then
    error "Could not detect a recommended NVIDIA driver."
fi


log "Recommended driver: $DRIVER"


# --- DRIVER INSTALL -----------------------------------------------------------
log "Installing NVIDIA driver"
apt install -y "$DRIVER"


# --- OPTIONAL CUDA TOOLKIT ----------------------------------------------------
if [ "${INSTALL_CUDA:-0}" = "1" ]; then
    log "Installing CUDA toolkit (Ubuntu repo)"
    apt install -y nvidia-cuda-toolkit
fi


# --- REBOOT NOTICE ------------------------------------------------------------
sudo nvidia-smi -pm 1
log "Installation complete. A reboot is required."


cat <<EOF


===============================================================================
NVIDIA driver installation finished.


NEXT STEPS:
1. Reboot the system:
     sudo reboot


2. Verify after reboot:
     nvidia-smi


Optional:
- Enable persistence mode:
     sudo nvidia-smi -pm 1


- Install CUDA during install:
     sudo INSTALL_CUDA=1 ./install.sh
===============================================================================
EOF

