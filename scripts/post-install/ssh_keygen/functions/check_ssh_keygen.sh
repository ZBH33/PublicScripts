#!/usr/bin/env bash

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

VERBOSITY=3
CONFIG_FILE="${SCRIPT_DIR}/config.conf"

# Template counters for summary or status tracking
processed_count=0
success_count=0
failed_count=0

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

example_task() {
    processed_count=$((processed_count + 1))

    if true; then
        success_count=$((success_count + 1))
        echo "Example task succeeded"
    else
        failed_count=$((failed_count + 1))
        echo "Example task failed" >&2
        return 1
    fi
}
# Answer is yes function
function answer_yes() {
	case "$1" in
		[Yy]|[Yy][Ee][Ss])
			return 0
			;;
		*)
			return 1
			;;
	esac
}

# Answer is no function
function answer_no() {
	case "$1" in
		[Nn]|[Nn][Oo])
			return 0
			;;
		*)
			return 1
			;;
	esac
}

# Parse command line options
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
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

check_requirements() {
print_warning "Updating system packages..."
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
print_warning "Installing essential packages..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    openssh-server   

}

check_ssh_keygen() {
# Does ssh-keygen exist?
if command -v ssh-keygen &> /dev/null; then
    print_success "Open-ssh is Installed"
else
    check_requirements
    exit 1
fi

# Create SSH path
ssh_folder="$HOME/.ssh"
if [ ! -d "$ssh_folder" ]; then
    print_warning "Creating$ssh_folder"
    mkdir -p "$ssh_folder"
fi

keyname="$HOSTNAME@$OS_TYPE" # get keyname based on the users OS
# Check if key already exists
if [ -e "$ssh_folder/$keyname" ]; then
    while true; do

	print_error "The key already exists! Do you want to overwrite it?"
	read -p " Enter your choice (y/n): " answer_overwrite_key
	
	if answer_yes "$answer_overwrite_key"; then
	    print_warning "Overwritting keypair... Press enter twice and leave the passphrase empty for now"
	    sleep 1
	    rm "$ssh_folder/$keyname" && rm "$ssh_folder/$keyname.pub"
	    ssh-keygen -t rsa -f $ssh_folder/$keyname
	    print_success "ssh keypair $keyname and $keyname.pub have been overwritten!"
	    break
	elif answer_no "$answer_overwrite_key"; then
	    print_error "Exiting..."
	    exit 1
	else
	    echo ""
	fi
    done
    # Create the key if it doesn't exist
else
    ssh-keygen -t rsa -f $ssh_folder/$keyname
    print_success "ssh keypair $keyname and $keyname.pub have been created"
fi

# Create or overwrite SSH config file
config_file="$ssh_folder/config"
if [ -e "$config_file" ]; then
    
    while true; do
    
	print_error "The config file already exists!Do you want to overwrite it?"
	read -p " Enter your choice (y/n): " answer_overwrite

	if answer_yes "$answer_overwrite"; then
	    cat << EOF > "$config_file"
# ===========================
# GLOBAL DEFAULTS
# ===========================
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 120
    AddKeysToAgent yes
    ForwardAgent yes
    IdentityFile ~/.ssh/$keyname
    IdentitiesOnly yes
    TCPKeepAlive yes
# ===========================
# $keyname
# ===========================
Host $keyname
    HostName 192.168.0.240
    User zbh33
    IdentityFile ~/.ssh/$keyname
    ForwardX11 no
    ForwardX11Trusted no
    Compression yes
    IdentitiesOnly yes
    TCPKeepAlive yes
    ServerAliveInterval 60
    ServerAliveCountMax 120
    AddKeysToAgent yes
    ForwardAgent yes
# ===========================
# Github
# ===========================
    Host github.com 
    User git 
    Hostname github.com 
    PreferredAuthentications publickey 
    IdentityFile ~/.ssh/Workstation@windows
    AddKeysToAgent yes
    ForwardAgent yes
EOF
	    print_success "Config file overwritten!"
	    break
	elif answer_no "$answer_overwrite"; then
	    print_error "Exiting..."
	    exit 1
	else
	    echo ""
	fi
    done
else
    cat << EOF > "$config_file"
# ===========================
# GLOBAL DEFAULTS
# ===========================
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 120
    AddKeysToAgent yes
    ForwardAgent yes
    IdentityFile ~/.ssh/$keyname
    IdentitiesOnly yes
    TCPKeepAlive yes
# ===========================
# $keyname
# ===========================
Host $keyname
    HostName 192.168.0.240
    User zbh33
    IdentityFile ~/.ssh/$keyname
    ForwardX11 no
    ForwardX11Trusted no
    Compression yes
    IdentitiesOnly yes
    TCPKeepAlive yes
    ServerAliveInterval 60
    ServerAliveCountMax 120
    AddKeysToAgent yes
    ForwardAgent yes
# ===========================
# Github
# ===========================
    Host github.com 
    User git 
    Hostname github.com 
    PreferredAuthentications publickey 
    IdentityFile ~/.ssh/Workstation@windows
    AddKeysToAgent yes
    ForwardAgent yes
EOF
    print_success "Config file created!"
fi
}


# ============================================================================
# MAIN LOGIC
# ============================================================================
# Orchestrates script execution.
# This function should read clearly from top to bottom.

main() {
    check_ssh_keygen
}


# ============================================================================
# SCRIPT ENTRY POINT
# ============================================================================
# Ensures the script runs only when executed directly,
# not when sourced by another script.

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi


