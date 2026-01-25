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

end_motd () {
    print_warning "Go to https://github.com/settings/profile -> SSH and GPG Keys"
    print_warning "Choose New SSH key and paste the .pub key contents in your clipboard"
}


# ============================================================================
# MAIN LOGIC
# ============================================================================
# Orchestrates script execution.
# This function should read clearly from top to bottom.

main() {
    end_motd
}


# ============================================================================
# SCRIPT ENTRY POINT
# ============================================================================
# Ensures the script runs only when executed directly,
# not when sourced by another script.

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi


