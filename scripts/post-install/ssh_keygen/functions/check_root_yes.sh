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
# File Name : check_root.sh
# Purpose   : Starter function for executable Bash scripts
# Usage     : MUST define this script as Source module
#           :
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
#           : 
# Author    : ZBH33
# Version   : 0.0.1
# Created   : 26-01-2026
# ============================================================================


# ============================================================================
# SCRIPT SOURCING
# ============================================================================
# Source reusable modules here.
# These files MUST define functions only and must not execute logic.


# ============================================================================
# CONFIGURATION
# ============================================================================
# Define constants and configurable values here only.

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


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

check_root_yes() {
    # Determine the effective user ID (EUID).
    # - EUID is preferred when available (Bash, some shells).
    # - Fallback to `id -u` for strict POSIX compatibility.
    local effective_uid="${EUID:-$(id -u)}"
    
    # If the effective UID is not 0, the script is not running as root.
    if [ "${effective_uid}" -ne 0 ]; then
        # If a custom error-printing function exists, use it.
        if command -v print_error >/dev/null 2>&1; then
            print_error "This script must be run as root."
        else
            # Fallback to a standard error message.
            echo "ERROR: This script must be run as root." >&2
        fi

        # Exit with a non-zero status to prevent unsafe execution.
        exit 1
    fi
}


# ============================================================================
# MAIN LOGIC
# ============================================================================
# The main execution flow starts here.

main() {
    # Run detection
    check_root
}

# ============================================================================
# SCRIPT ENTRY POINT
# ============================================================================
# Ensures main() runs only when the script is executed directly,
# not when it is sourced.

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
