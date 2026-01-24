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

sudo apt-get updatel
sudo apt-get install -y git

wget https://raw.githubusercontent.com/ZBH33/PublicScripts/refs/heads/main/scripts/GithubKey/CreateSSH-GithubKey.sh
sudo chmod +x CreateSSH-GithubKey.sh
sudo ./CreateSSH-GithubKey.sh

echo "Installation starting..."

wget https://raw.githubusercontent.com/ZBH33/PublicScripts/refs/heads/main/install.sh
sudo chmod +x install.sh
sudo ./install.sh
