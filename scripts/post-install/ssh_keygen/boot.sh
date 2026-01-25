#!/bin/bash

set -euo pipefail

echo "=> Ubuntu Server installations only!"
echo "Beginning Keygen for OpenSSH files!"

echo "Installation starting..."
source ~/.local/share/publicscripts/scripts/post-install/ssh_keygen/install.sh
