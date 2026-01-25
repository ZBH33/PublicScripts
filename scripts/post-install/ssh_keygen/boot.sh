#!/bin/bash

set -euo pipefail

clear
echo "=> Ubuntu Server installations only!"
echo -e "/nBegin Keygen"

echo "Cloning PublicScripts..."
rm -rf ~/.local/share/PublicScripts
git clone https://github.com/ZBH33/PublicScripts.git ~/.local/share/PublicScripts >/dev/null

echo "Installation starting..."
source ~/.local/share/PublicScripts/scripts/post-install/ssh_keygen/install.sh
