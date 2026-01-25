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
# File Name : detect_os.sh
# Purpose   : Starter function for executable Bash scripts
# Usage     : MUST define this script as Source module
#           :
#           : Example:
#           : #!/bin/bash
#           :
#           : # ============================================================================
#           : # CONFIGURATION
#           : # ============================================================================
#           : # Define constants and configurable values here only.
#           : 
#           : SCRIPT_NAME="$(basename "$0")"
#           : SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#           : source "${SCRIPT_DIR}/os_detect.sh"
#           :
#           : # ============================================
#           : # FUNCTIONS
#           : # ============================================
#           : # Place reusable logic here. Prefer small, single-purpose functions.
#           : 
#           : # ============================================
#           : # MAIN EXECUTION
#           : # ============================================
#           : # Orchestrates script execution.
#           : # This function should read clearly from top to bottom.
#           : 
#           : # ============================================================================
#           : # SCRIPT ENTRY POINT
#           : # ============================================================================
#           : # Ensures the script runs only when executed directly,
#           : # not when sourced by another script.
#           : 
#           : if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
#           :     main "$@"
#           : fi
#           : 
# Author    : ZBH33
# Version   : 0.0.1
# Created   : 26-01-2026
# ============================================================================


# ============================================================================
# CONFIGURATION
# ============================================================================
# Define constants and configurable values here only.

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

OS_TYPE=""  # Will be set to: "linux", "macos", or "windows"

# ============================================================================
# SCRIPT SOURCING
# ============================================================================
# Source reusable modules here.
# These files MUST define functions only and must not execute logic.

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

# Simple OS detection function
detect_os() {
    local kernel_name=$(uname -s)
    
    case "$kernel_name" in
        "Linux")
            OS_TYPE="linux"
            ;;
        "Darwin")
            OS_TYPE="macos"
            ;;
        "CYGWIN"*|"MINGW"*|"MSYS"*)
            OS_TYPE="windows"
            ;;
        *)
            OS_TYPE="unknown"
            if [ -f /proc/version ] && grep -qi "microsoft" /proc/version; then
                OS_TYPE="linux"  # WSL detection
            fi
            ;;
    esac
}

# Quick detection without function call (auto-runs when sourced)
if [ -z "$OS_TYPE" ]; then
    detect_os
fi

# Return success if detection worked
if [ "$OS_TYPE" != "unknown" ] && [ -n "$OS_TYPE" ]; then
    true  # Success
else
    false  # Failure
fi

# ============================================================================
# MAIN LOGIC
# ============================================================================
# The main execution flow starts here.

main() {
    # Run detection
    detect_os
}

# ============================================================================
# SCRIPT ENTRY POINT
# ============================================================================
# Ensures main() runs only when the script is executed directly,
# not when it is sourced.

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
