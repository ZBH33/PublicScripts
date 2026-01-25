#!/usr/bin/env bash

# ============================================================================
# DEFENSIVE SHELL OPTIONS — MUST BE AT THE VERY BEGINNING
# ============================================================================
set -eu
set -o pipefail 2>/dev/null || echo "Warning: pipefail not supported" >&2
# ============================================================================

# ============================================================================
# MODULE    : message_utils.sh
# PURPOSE   : Colored message output and optional error handling helpers
# NOTE      : This file is intended to be sourced, not executed.
#           : Example:
#           : #!/usr/bin/env bash
#           :
#           : # ==============================================================
#           : # SCRIPT SOURCING
#           : # ==============================================================
#           : # Source reusable modules here.
#           : # MUST define functions only and must not execute logic.
#           : 
#           : # source "${SCRIPT_DIR}/message_utils.sh"
#           : # source "${SCRIPT_DIR}/os_detect.sh"
#           : 
#           : #!/end/of/file
# Author    : ZBH33
# Version   : 0.0.1
# Created   : YYYY-MM-DD
# ============================================================================
# ============================================================================


# ============================================================================
# CONFIGURATION (AESTHETICS)
# ============================================================================

# --- Aesthetics --- 
GREEN='\033[0;32m' 
YELLOW='\033[1;33m' 
RED='\033[0;31m' 
ICON='\xF0\x9F\x8C\x80' 
NC='\033[0m'

# Unicode icon shown before each message
# Chosen as a byte-safe escape sequence to avoid locale issues
MSG_ICON='\xF0\x9F\x8C\x80'


# ============================================================================
# INTERNAL HELPER
# ============================================================================
# Prints a colored message with a shared icon.
_print_message() {
    local color="$1"
    local message="$2"

    # -e is required to interpret ANSI escape sequences
    echo -e "${color}${MSG_ICON} ${message}${NC}"
}

# ============================================================================
# PUBLIC MESSAGE FUNCTIONS
# ============================================================================
# These functions are intended to be called by the sourcing script.

print_error() {
    _print_message "${RED}" "ERROR: $1"
}

print_warning() {
    _print_message "${YELLOW}" "WARNING: $1"
}

print_success() {
    _print_message "${GREEN}" "SUCCESS: $1"
}

# ============================================================================
# ERROR HANDLING SUPPORT
# ============================================================================
# Handles fatal errors when used with a trap.
# Arguments:
#   $1 - Line number where the error occurred
handle_error() {
    local line_number="$1"

    print_error "Script failed on line ${line_number}"
    print_error "Please check the output above for more information"
    exit 1
}

# ============================================================================
# OPTIONAL TRAP SETUP
# ============================================================================
# IMPORTANT:
# Traps should NOT be enabled automatically in sourced files.
# The calling script must explicitly opt in by calling:
#
#   enable_error_trap
#
enable_error_trap() {
    trap 'handle_error ${LINENO}' ERR
}
