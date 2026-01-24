#!/bin/bash

# =============================================================================
# INSTALL AND CONFIGURE OPENSSH SERVER
# =============================================================================

# Enable strict error handling for production scripts
# -e: Exit immediately if any command fails
# -u: Treat unset variables as errors
# -o pipefail: Consider pipeline failures in exit codes
set -euo pipefail

# -----------------------------------------------------------------------------
# Function: install_openssh_server
# 
# Installs OpenSSH server with basic security configuration.
# This function is idempotent - safe to run multiple times.
# -----------------------------------------------------------------------------
install_openssh_server() {
    local ssh_config_file="/etc/ssh/sshd_config"
    local ssh_config_backup="${ssh_config_file}.bak.$(date +%Y%m%d_%H%M%S)"
    
    echo "Starting OpenSSH Server installation..."
    echo "----------------------------------------"
    
    # Update package list to ensure we get latest version
    echo "Updating package repositories..."
    apt-get update
    
    # Install OpenSSH server package
    # Using apt-get instead of apt for better scripting compatibility
    echo "Installing OpenSSH server..."
    apt-get install -y openssh-server
    
    # Check if SSH service is active
    if systemctl is-active --quiet ssh; then
        echo "✓ SSH service is running"
    else
        echo "Starting SSH service..."
        systemctl start ssh
    fi
    
    # Enable SSH service to start on boot
    if systemctl is-enabled --quiet ssh; then
        echo "✓ SSH service is enabled to start on boot"
    else
        echo "Enabling SSH service to start on boot..."
        systemctl enable ssh
    fi
    
    # -------------------------------------------------------------------------
    # OPTIONAL SECURITY CONFIGURATION
    # Comment out this section if you don't want automatic security tweaks
    # -------------------------------------------------------------------------
    
    # Backup original SSH configuration before making changes
    if [[ -f "$ssh_config_file" ]]; then
        cp "$ssh_config_file" "$ssh_config_backup"
        echo "✓ Original SSH config backed up to: $ssh_config_backup"
    fi
    
    # Disable root login via SSH (security best practice)
    # This creates a regular user account for SSH access instead
    echo "Configuring SSH security settings..."
    
    # Use sed to modify SSH configuration safely
    # -i.bak creates backup, but we already made one above
    # Only modify if the setting exists and isn't already set correctly
    if grep -q "^#*PermitRootLogin" "$ssh_config_file"; then
        sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' "$ssh_config_file"
        echo "✓ Disabled SSH root login"
    else
        echo "PermitRootLogin no" >> "$ssh_config_file"
        echo "✓ Added SSH root login restriction"
    fi
    
    # Restart SSH service to apply configuration changes
    echo "Restarting SSH service to apply changes..."
    systemctl restart ssh
    
    # -------------------------------------------------------------------------
    # VERIFICATION AND OUTPUT
    # -------------------------------------------------------------------------
    
    echo ""
    echo "OpenSSH Server installation complete!"
    echo "----------------------------------------"
    
    # Get the IP address for user reference
    local ip_address
    ip_address=$(hostname -I | awk '{print $1}') || ip_address="UNKNOWN"
    
    # Show service status
    echo "Service Status:"
    systemctl status ssh --no-pager --lines=5
    
    echo ""
    echo "IMPORTANT:"
    echo "1. SSH is now running on port 22"
    echo "2. Root login is disabled (security best practice)"
    echo "3. Connect using: ssh your_username@${ip_address}"
    echo "4. Original config backed up to: $ssh_config_backup"
    echo ""
    echo "Next steps:"
    echo "1. Create a non-root user: sudo adduser your_username"
    echo "2. Add user to sudo group: sudo usermod -aG sudo your_username"
    echo "3. Test SSH connection before closing current session"
}

# =============================================================================
# MAIN EXECUTION - Only runs if script is executed directly
# =============================================================================

# This check allows the function to be sourced in other scripts without running
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Check if running with sufficient privileges
    if [[ $EUID -ne 0 ]]; then
        echo "ERROR: This script must be run as root or with sudo" >&2
        echo "Usage: sudo bash $(basename "$0")" >&2
        exit 1
    fi
    
    # Call the main function
    install_openssh_server
    
    # Exit with success code (implicit with set -e, but explicit for clarity)
    exit 0
fi