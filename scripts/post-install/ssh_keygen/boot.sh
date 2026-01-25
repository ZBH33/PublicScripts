#!/bin/bash

set -euo pipefail

print_warning "=> Ubuntu Server installations only!"
print_warning "Beginning Keygen for OpenSSH files!"

print_error "Installation starting..."
source ~/.local/share/publicscripts/scripts/post-install/ssh_keygen/install.sh
