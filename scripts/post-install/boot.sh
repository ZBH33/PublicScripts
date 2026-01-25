#!/bin/bash

set -euo pipefail

echo "=> Ubuntu Server installations only!"
echo -e "\nBegin installation (or abort with ctrl+c)..."

sudo apt-get update 
sudo apt-get install -y git 

echo "Cloning Public Scripts..."
rm -rf ~/.local/share/publicscripts
git clone https://github.com/zbh33/publicscripts.git ~/.local/share/publicscripts 

echo "Installation starting..."
source ~/.local/share/publicscripts/scripts/post-install/install.sh
