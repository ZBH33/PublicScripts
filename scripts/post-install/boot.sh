#!/bin/bash

set -euo pipefail

banner='▄▄▄▄▄▄              ▄▄      ▄▄▄▄         ██                        
        ██▀▀▀▀█▄            ██      ▀▀██         ▀▀                        
        ██    ██  ██    ██  ██▄███▄   ██       ████      ▄█████▄           
        ██████▀   ██    ██  ██▀  ▀██  ██         ██     ██▀    ▀           
        ██        ██    ██  ██    ██  ██         ██     ██                 
        ██        ██▄▄▄███  ███▄▄██▀  ██▄▄▄   ▄▄▄██▄▄▄  ▀██▄▄▄▄█           
        ▀▀         ▀▀▀▀ ▀▀  ▀▀ ▀▀▀     ▀▀▀▀   ▀▀▀▀▀▀▀▀    ▀▀▀▀▀            
        ▄▄▄▄                         ██                                  
      ▄█▀▀▀▀█                        ▀▀                 ██               
      ██▄        ▄█████▄   ██▄████ ████     ██▄███▄   ███████   ▄▄█████▄ 
      ▀████▄   ██▀    ▀   ██▀       ██     ██▀  ▀██    ██      ██▄▄▄▄ ▀ 
          ▀██  ██         ██        ██     ██    ██    ██       ▀▀▀▀██▄ 
      █▄▄▄▄▄█▀  ▀██▄▄▄▄█   ██     ▄▄▄██▄▄▄  ███▄▄██▀    ██▄▄▄   █▄▄▄▄▄██ 
      ▀▀▀▀▀      ▀▀▀▀▀    ▀▀     ▀▀▀▀▀▀▀▀  ██ ▀▀▀       ▀▀▀▀    ▀▀▀▀▀▀  
                                            ██
'

echo -e "$banner"
echo "=> For fresh Ubuntu Server installations only!"
echo -e "\nBegin installation (or abort with ctrl+c)..."

sudo apt-get update >/dev/null
sudo apt-get install -y git >/dev/null

echo "Cloning Public Scripts..."
rm -rf ~/.local/share/publicscripts
git clone https://github.com/zbh33/publicscripts.git ~/.local/share/publicscripts >/dev/null

echo "Installation starting..."
source ~/.local/share/publicscripts/scripts/post-install/install.sh
