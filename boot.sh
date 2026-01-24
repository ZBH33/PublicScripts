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

PUBLICSCRIPTS_REF=${PUBLICSCRIPTS_REF:-"main"}

if [[ $PUBLICSCRIPTS_REF != "main" ]]; then
  cd ~/.local/share/publicscripts
  git fetch origin "$PUBLICSCRIPTS_REF" && git checkout "$PUBLICSCRIPTS_REF"
  cd - >/dev/null
fi

echo "Installation starting..."
source ~/.local/share/publicscripts/scripts/GithubKey/CreateSSH-GithubKey.sh
source ~/.local/share/publicscripts/install.sh
