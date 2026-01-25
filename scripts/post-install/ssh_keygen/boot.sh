#!/bin/bash

set -euo pipefail

echo "=> Ubuntu Server installations only!"
echo -e "\nBegin Keygen"

echo "Cloning PublicScripts..."
rm -rf ~/.local/share/scripts
git clone https://github.com/ZBH33/PublicScripts.git ~/.local/share/ubinkaze >/dev/null

echo "Installation starting..."
source ~/.local/share/scripts/PublicScripts/scripts/post-install/install.sh
