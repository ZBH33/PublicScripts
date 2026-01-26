#!/bin/bash
# ============================================================================
# DEFENSIVE SHELL OPTIONS — MUST BE AT THE VERY BEGINNING
# ============================================================================
set -eu
set -o pipefail 2>/dev/null || echo "Warning: pipefail not supported" >&2
# ============================================================================


# ============================================================================
# SCRIPT METADATA
# ============================================================================
# File Name : template.sh
# Purpose   : Starter template for executable Bash scripts
# Usage     : ./template.sh [options]
#           : Example:
#           : #!/bin/bash
#           :
#           : # ==============================================================
#           : # SCRIPT SOURCING
#           : # ==============================================================
#           : # Source reusable modules here.
#           : # MUST define functions only and must not execute logic.
#           : 
#           : # source "${SCRIPT_DIR}/check_root.sh"
#           : # source "${SCRIPT_DIR}/os_detect.sh"
#           : 
#           : #!/end/of/file
# Author    : ZBH33
# Version   : 0.0.1
# Created   : YYYY-MM-DD
# ============================================================================


# ============================================================================
# CONFIGURATION
# ============================================================================
# Define constants and configurable values here only.

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


# ============================================================================
# SCRIPT SOURCING
# ============================================================================
# Source reusable modules here.
# These files MUST define functions only and must not execute logic.

# Example:
# SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# source "${SCRIPT_DIR}/check_root.sh"
# source "${SCRIPT_DIR}/os_detect.sh"


# ============================================================================
# FUNCTION DEFINITIONS
# ============================================================================
# Place reusable logic here. Prefer small, single-purpose functions.

print_usage() {
    cat <<EOF
Usage: ${SCRIPT_NAME}

Description:
  This script is based on a reusable Bash template.

Options:
  -h    Show this help message
EOF
}


# Parse command line options
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            print_usage
            exit 0
            ;;
        -*)
            echo "Error: Unknown option $1"
            print_usage
            exit 1
            ;;
        *)
    esac
done

start_up() {
clear
echo "=> Ubuntu Server installations only!"
echo -e "/nBegin Keygen"
sleep 1
sudo apt-get update 
sudo apt-get install -y git 
sleep 1
}

clone_publicscripts() {
echo "Cloning PublicScripts..."
rm -rf ~/.local/share/PublicScripts
git clone https://github.com/ZBH33/PublicScripts.git ~/.local/share/PublicScripts >/dev/null
cd ~/.local/share/PublicScripts/scripts/post-install/ssh_keygen
chmod +x boot.sh
chmod +x install.sh
}

run_install() {
    cd ~/.local/share/PublicScripts/scripts/post-install/ssh_keygen
    ./install.sh
}
# ============================================================================
# MAIN LOGIC
# ============================================================================
# Orchestrates script execution.
# This function should read clearly from top to bottom.

main() {
    # Print Message at Startup
    start_up

    # Clone Repo
    clone_publicscripts

    # Run install.sh
    run_install

    run_next_script  "~/.local/share/PublicScripts/scripts/NVIDIA/boot.sh"
}


# ============================================================================
# SCRIPT ENTRY POINT
# ============================================================================
# Ensures the script runs only when executed directly,
# not when sourced by another script.

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
