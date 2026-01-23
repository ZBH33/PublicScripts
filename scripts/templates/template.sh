#!/bin/bash

# ============================================================================
# DEFENSIVE SHELL OPTIONS - MUST BE AT THE VERY BEGINNING
# ============================================================================
# Store current shell options
OLD_SET_OPTIONS="$-"

# Enable defensive options
set -eu

# pipefail is trickier - we'll set it but be careful
set -o pipefail || {
    echo "Warning: pipefail not supported, some error detection may be limited" >&2
}
# ============================================================================

# ============================================================================
# 
#
# ============================================================================
# Author: ZBH33
# Version: 1.0
# ============================================================================

# ============================================
# CONFIGURATION
# ============================================

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "$0")"

# Configuration files
CONFIG_FILE="${SCRIPT_DIR}/config.conf"

# Default settings
VERBOSITY=3  # Default verbosity level: INFO and above

CURRENT_DATE=$(date '+%Y-%m-%d')
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

# ============================================
# PATH UTILITY FUNCTIONS
# ============================================

# Path utility functions
normalize_path() {
    local path="$1"
    
    # Convert Windows paths to Unix style if needed
    if [[ "$path" =~ ^[A-Za-z]: ]]; then
        # Windows path with drive letter
        local drive_letter="${path:0:1}"
        local rest="${path:2}"
        path="/${drive_letter,,}${rest//\\//}"
    fi
    
    # Remove duplicate slashes
    echo "$path" | sed 's|//*|/|g'
}

join_paths() {
    local base="$1"
    local rel="$2"
    
    base=$(normalize_path "$base")
    rel=$(normalize_path "$rel")
    
    # Remove trailing slash from base
    base="${base%/}"
    
    # Remove leading slash from relative
    rel="${rel#/}"
    
    echo "${base}/${rel}"
}

# ============================================
# LOGGING MODULE (EMBEDDED)
# ============================================

# Logging Configuration - defaults, can be overridden by config file
LOG_DIR=$(join_paths "${HOME}" "logs/${SCRIPT_NAME}/logs_$(date '+%Y%m%d')")
LOG_FILE=""  # Will be set in init_logging after LOG_DIR is created
ERROR_LOG_FILE=""  # Will be set in init_logging after LOG_DIR is created
# Default log settings - can be overridden by config
: "${MAX_LOG_SIZE_MB:=10}"  # Use default of 10 if not set in config
: "${MAX_LOG_FILES:=30}"    # Use default of 30 if not set in config

# Color definitions (for terminal output only)
if [ -t 1 ]; then
    NC='\033[0m'        # No Color
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    MAGENTA='\033[0;35m'
    BOLD='\033[1m'
else
    NC=''
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    MAGENTA=''
    BOLD=''
fi

# Numeric log levels for comparison
LOG_LEVEL_FATAL=0
LOG_LEVEL_ERROR=1
LOG_LEVEL_WARNING=2
LOG_LEVEL_INFO=3
LOG_LEVEL_SUCCESS=3  # Same as INFO level
LOG_LEVEL_DEBUG=4

# Get current verbosity description
get_verbosity_description() {
    case "$VERBOSITY" in
        0) echo "FATAL only (quiet)" ;;
        1) echo "ERROR and above" ;;
        2) echo "WARNING and above" ;;
        3) echo "INFO and above (normal)" ;;
        4) echo "DEBUG and above (verbose)" ;;
        *) echo "Unknown ($VERBOSITY)" ;;
    esac
}

# Initialize logging system
init_logging() {
    # Create log directory first - CRITICAL: Must create directory BEFORE any log_message calls
    mkdir -p "$LOG_DIR" 2>/dev/null || {
        # Use echo for initial error since logging isn't ready yet
        echo "[ERROR] Failed to create log directory: $LOG_DIR" >&2
        return 1
    }
    
    # Now that directory exists, we can define log files
    LOG_FILE="${LOG_DIR}/${SCRIPT_NAME}_$(date '+%Y%m%d').log"
    ERROR_LOG_FILE="${LOG_DIR}/${SCRIPT_NAME}_errors_$(date '+%Y%m%d').log"
    
    # Rotate logs if they exceed maximum size
    rotate_logs "$LOG_FILE" "$MAX_LOG_SIZE_MB"
    rotate_logs "$ERROR_LOG_FILE" "$MAX_LOG_SIZE_MB"
    
    # Clean up old log files
    cleanup_old_logs
    
    # Log initialization - only now that files are ready
    log_message "INFO" "Logging initialized"
    log_message "DEBUG" "Log verbosity level set to: $VERBOSITY"
    log_message "DEBUG" "Main log: $LOG_FILE"
    log_message "DEBUG" "Error log: $ERROR_LOG_FILE"
    
    return 0
}

# Get numeric value for log level
get_log_level_number() {
    local level="$1"
    case "$level" in
        "FATAL")   echo $LOG_LEVEL_FATAL ;;
        "ERROR")   echo $LOG_LEVEL_ERROR ;;
        "WARNING") echo $LOG_LEVEL_WARNING ;;
        "INFO")    echo $LOG_LEVEL_INFO ;;
        "SUCCESS") echo $LOG_LEVEL_SUCCESS ;;
        "DEBUG")   echo $LOG_LEVEL_DEBUG ;;
        *)         echo $LOG_LEVEL_INFO ;;  # Default
    esac
}

# Check if message should be displayed based on verbosity
should_log() {
    local message_level="$1"
    local message_level_num=$(get_log_level_number "$message_level")
    
    # Always show FATAL and ERROR messages regardless of verbosity
    if [ "$message_level" = "FATAL" ] || [ "$message_level" = "ERROR" ]; then
        return 0
    fi
    
    # Check if message level is within current verbosity
    if [ "$message_level_num" -le "$VERBOSITY" ]; then
        return 0
    else
        return 1
    fi
}

# Rotate log file if it exceeds maximum size
rotate_logs() {
    local log_file="$1"
    local max_size_mb="$2"
    
    [ -f "$log_file" ] || return 0
    
    local size_bytes=$(stat -c%s "$log_file" 2>/dev/null || stat -f%z "$log_file" 2>/dev/null)
    local size_mb=$((size_bytes / 1024 / 1024))
    
    if [ "$size_mb" -ge "$max_size_mb" ]; then
        local timestamp=$(date '+%Y%m%d_%H%M%S')
        local rotated_file="${log_file}.${timestamp}"
        mv "$log_file" "$rotated_file" 2>/dev/null && \
        log_message "INFO" "Rotated log file: $log_file -> $rotated_file"
    fi
}

# Clean up old log files
cleanup_old_logs() {
    local pattern="${LOG_DIR}/*.log.*"
    local files=($(ls -t $pattern 2>/dev/null))
    local count=${#files[@]}
    
    if [ "$count" -gt "$MAX_LOG_FILES" ]; then
        for ((i=MAX_LOG_FILES; i<count; i++)); do
            rm -f "${files[$i]}" 2>/dev/null && \
            log_message "DEBUG" "Removed old log file: ${files[$i]}"
        done
    fi
}

# Main logging function
log_message() {
    local level="${1:-INFO}"
    local message="${2:-}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local line_number="${BASH_LINENO[0]}"
    
    # Format log entry with additional context
    local log_entry="[$timestamp] [$level] [${SCRIPT_NAME}:${line_number}] $message"
    
    # Always write to main log file (full logging)
    echo "$log_entry" >> "$LOG_FILE"
    
    # Write to error log for error levels
    case "$level" in
        "ERROR"|"FATAL")
            echo "$log_entry" >> "$ERROR_LOG_FILE"
            
            # For FATAL errors, optionally send notification
            if [ "$level" = "FATAL" ]; then
                send_alert "$log_entry"
            fi
            ;;
    esac
    
    # Terminal output with colors and verbosity control
    if should_log "$level"; then
        case "$level" in
            "DEBUG")
                # DEBUG messages only show when verbosity is 4+
                if [ "$VERBOSITY" -ge 4 ]; then
                    echo -e "${CYAN}[DEBUG]${NC} $message" >&2
                fi
                ;;
            "INFO")
                echo -e "${BLUE}[INFO]${NC} $message" >&2
                ;;
            "SUCCESS")
                echo -e "${GREEN}[SUCCESS]${NC} $message" >&2
                ;;
            "WARNING")
                echo -e "${YELLOW}[WARNING]${NC} $message" >&2
                ;;
            "ERROR")
                echo -e "${RED}[ERROR]${NC} $message" >&2
                ;;
            "FATAL")
                echo -e "${BOLD}${RED}[FATAL]${NC} $message" >&2
                ;;
            *)
                echo -e "${MAGENTA}[$level]${NC} $message" >&2
                ;;
        esac
    fi
}

# Set verbosity level
set_verbosity() {
    local level="$1"
    case "$level" in
        0|1|2|3|4)
            VERBOSITY=$level
            log_message "DEBUG" "Verbosity level changed to: $VERBOSITY"
            ;;
        "FATAL"|"fatal")
            VERBOSITY=0
            ;;
        "ERROR"|"error")
            VERBOSITY=1
            ;;
        "WARNING"|"warning")
            VERBOSITY=2
            ;;
        "INFO"|"info")
            VERBOSITY=3
            ;;
        "DEBUG"|"debug")
            VERBOSITY=4
            ;;
        *)
            log_message "WARNING" "Invalid verbosity level: $level. Using default (3)"
            VERBOSITY=3
            ;;
    esac
}

# Log command execution with error trapping
log_and_run() {
    local command="$1"
    local description="${2:-$command}"
    
    log_message "DEBUG" "Executing: $description"
    
    # Temporarily disable set -e for this function
    # This allows us to capture and handle errors without exiting
    set +e
    
    # Execute command and capture output
    local output
    local exit_code
    
    output=$(eval "$command" 2>&1)
    exit_code=$?
    
    # Restore set -e
    set -e
    
    if [ $exit_code -eq 0 ]; then
        log_message "SUCCESS" "Command completed successfully: $description"
        # Show output only in debug mode
        if [ -n "$output" ] && [ "$VERBOSITY" -ge 4 ]; then
            log_message "DEBUG" "Output: $output"
        fi
    else
        log_message "ERROR" "Command failed with exit code $exit_code: $description"
        if [ -n "$output" ]; then
            log_message "ERROR" "Error output: $output"
        fi
    fi
    
    return $exit_code
}

# Send alert for critical errors (example implementation)
send_alert() {
    local message="$1"
    
    # Example: Send email (requires mail command)
    # echo "$message" | mail -s "Script Error Alert" admin@example.com
    
    # Example: Send to syslog
    logger -t "$(basename "$0")" "FATAL_ERROR: $message"
    
    # Example: Send to external monitoring service
    # curl -X POST -H "Content-Type: application/json" \
    #      -d "{\"message\":\"$message\"}" \
    #      https://monitoring.example.com/alerts >/dev/null 2>&1
    
    log_message "DEBUG" "Alert sent for: $message"
}

# Create a stack trace on error
log_stack_trace() {
    local depth=${1:-10}
    
    # Only show stack trace in DEBUG mode
    if [ "$VERBOSITY" -ge 4 ]; then
        log_message "DEBUG" "Stack trace (most recent call first):"
        for ((i=1; i<depth; i++)); do
            local func="${FUNCNAME[$i]}"
            local line="${BASH_LINENO[$((i-1))]}"
            local src="${BASH_SOURCE[$i]}"
            
            if [ -n "$func" ] && [ -n "$line" ] && [ -n "$src" ]; then
                log_message "DEBUG" "  $i: $func at $src:$line"
            fi
        done
    fi
}

# Log script termination
log_script_exit() {
    local exit_code=$?
    local signal="${1:-}"
    
    if [ -n "$signal" ]; then
        log_message "WARNING" "Script received signal: $signal"
    fi
    
    if [ $exit_code -eq 0 ]; then
        log_message "SUCCESS" "Script completed successfully"
    else
        log_message "ERROR" "Script exited with error code: $exit_code"
        log_stack_trace
    fi
    
    # Flush any buffered output
    sync 2>/dev/null
}

# Set up traps for error handling
setup_traps() {
    # Trap errors
    trap 'log_message "ERROR" "Error on line $LINENO"; log_stack_trace' ERR
    
    # Trap script exit
    trap 'log_script_exit' EXIT
    
    # Trap signals
    trap 'log_script_exit SIGINT' SIGINT
    trap 'log_script_exit SIGTERM' SIGTERM
    trap 'log_script_exit SIGHUP' SIGHUP
    
    log_message "DEBUG" "Traps configured for error handling"
}

# ============================================
# OS DETECTION MODULE (EMBEDDED)
# ============================================

# Simple OS detection function
detect_os_type() {
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
    
    # Ensure OS_TYPE is exported for all functions
    export OS_TYPE
}

# Initialize OS_TYPE with a default value before detection
OS_TYPE="unknown"

# Quick detection without function call (auto-runs when sourced)
detect_os_type

# ============================================
# CONFIGURATION LOADING FUNCTIONS
# ============================================

# Function to safely source configuration files
safe_source_config() {
    local config_file="$1"
    
    if [ ! -f "$config_file" ]; then
        log_message "DEBUG" "Config file not found: $config_file"
        return 1
    fi
    
    log_message "DEBUG" "Sourcing configuration from: $config_file"
    
    # Process the config file line by line to fix path issues
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$line" ]] && continue
        
        # Fix $(dirname "$0") references to use SCRIPT_DIR
        if [[ "$line" =~ '\$\(dirname\s*"\$0"\)' ]]; then
            line="${line//\$(dirname \"\$0\")/$SCRIPT_DIR}"
        fi
        
        # Evaluate the line
        eval "$line" 2>/dev/null || log_message "WARNING" "Failed to process config line: $line"
    done < "$config_file"
    
    log_message "DEBUG" "Configuration loaded successfully"
    return 0
}

# ============================================
# TEMPLATE HELPER FUNCTIONS
# ============================================

# Print usage information
print_usage() {
    cat << EOF
Usage: $0 [options] 

Template
===========================
template .sh bash file

Options:
  -d, --dry-run      Preview
  -l, --log DIR      Custom log directory (default: ~/.repo_setup/logs)
  -v, --verbose LEVEL  Set verbosity level (0-4, default: 3)
                      0: FATAL only (quiet)
                      1: ERROR and above
                      2: WARNING and above
                      3: INFO and above (normal)
                      4: DEBUG and above (verbose)
  -q, --quiet        Silent mode (equivalent to -v 0)
  -h, --help         Show this help message

Examples:


EOF
}

# Check for required commands
check_requirements() {
    log_message "DEBUG" "Checking system requirements..."
    
    local required_commands="git"
    local missing_commands=""
    local os_type="${OS_TYPE:-unknown}"
    
    for cmd in $required_commands; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_commands="$missing_commands $cmd"
        fi
    done
    
    if [ -n "$missing_commands" ]; then
        log_message "ERROR" "Missing required commands:${missing_commands}"
        
        # Offer to install git based on OS
        case "$os_type" in
            "linux")
                log_message "INFO" "To install git on Linux, run:"
                log_message "INFO" "  Ubuntu/Debian: sudo apt-get install git"
                log_message "INFO" "  CentOS/RHEL: sudo yum install git"
                log_message "INFO" "  Fedora: sudo dnf install git"
                log_message "INFO" "  Arch: sudo pacman -S git"
                ;;
            "macos")
                log_message "INFO" "To install git on macOS:"
                log_message "INFO" "  Option 1: brew install git"
                log_message "INFO" "  Option 2: Download from https://git-scm.com/download/mac"
                ;;
            "windows")
                log_message "INFO" "To install git on Windows:"
                log_message "INFO" "  Download Git for Windows from https://git-scm.com/download/win"
                ;;
            *)
                log_message "INFO" "To install git, visit: https://git-scm.com/downloads"
                ;;
        esac
        
        return 1
    else
        log_message "DEBUG" "All required commands are available"
        log_message "DEBUG" "Git version: $(git --version 2>/dev/null | head -n1)"
        return 0
    fi
}

# Load configuration from file
load_configuration() {
    log_message "INFO" "Loading configuration..."
    
    # Check for config file
    if [ -f "$CONFIG_FILE" ]; then
        log_message "INFO" "Loading configuration from: ${CONFIG_FILE}"
        
        # Safely source the config file with path fixes
        safe_source_config "$CONFIG_FILE"
        
        # Apply configuration overrides for logging
        if [ -n "${MAX_LOG_SIZE_MB_CONFIG:-}" ]; then
            MAX_LOG_SIZE_MB="$MAX_LOG_SIZE_MB_CONFIG"
            log_message "DEBUG" "Using config MAX_LOG_SIZE_MB: $MAX_LOG_SIZE_MB"
        fi
        
        if [ -n "${MAX_LOG_FILES_CONFIG:-}" ]; then
            MAX_LOG_FILES="$MAX_LOG_FILES_CONFIG"
            log_message "DEBUG" "Using config MAX_LOG_FILES: $MAX_LOG_FILES"
        fi
        
        log_message "SUCCESS" "Configuration loaded successfully"
    else
        log_message "INFO" "No configuration file found at ${CONFIG_FILE}, using defaults"
        
        # Create a sample config file
        create_sample_config
    fi
}

# Create a sample configuration file
create_sample_config() {
    cat > "${CONFIG_FILE}.example" << 'EOF'
# Repository Setup Configuration
# =============================

# Verbosity level: 0=minimal, 1=normal, 2=detailed, 3=debug
# VERBOSITY=1

# Retry settings
# MAX_RETRIES=2            # Number of retry attempts for failed clones
# RETRY_DELAY=5           # Seconds to wait between retries

# Log settings (use _CONFIG suffix to avoid variable conflicts)
# MAX_LOG_SIZE_MB_CONFIG=20      # Maximum log file size in MB
# MAX_LOG_FILES_CONFIG=50        # Maximum number of old log files to keep
EOF
    
    log_message "INFO" "Sample configuration created: ${CONFIG_FILE}.example"
}

# ============================================
# REPOSITORY FUNCTIONS
# ============================================

# Scan and display current folder contents
scan_current_folder() {
    log_message "DEBUG" "Scanning current working directory..."
    
    local current_dir="$(pwd)"
    log_message "DEBUG" "Current directory: ${current_dir}"
    
    # Count files and directories
    local file_count=$(find . -maxdepth 1 -type f | wc -l)
    local dir_count=$(find . -maxdepth 1 -type d | wc -l)

    log_message "DEBUG" "Contents: ${file_count} files, ${dir_count} directories (including .)"
    
    # List files with details (only in verbose mode)
    if [ "$VERBOSITY" -ge 4 ]; then
        log_message "DEBUG" "Detailed listing:"
        ls -la | while read line; do
            log_message "DEBUG" "  $line"
        done
    fi
}

# ============================================
# INITIALIZATION FUNCTIONS
# ============================================

# Initialize the setup
initialize_setup() {
    # Log verbosity setting
    log_message "DEBUG" "Verbosity level: $VERBOSITY ($(get_verbosity_description))"
    
    # Detect OS type
    log_message "DEBUG" "Detecting operating system..."
    log_message "DEBUG" "OS Type: ${OS_TYPE:-unknown}"
    
    # Check for required commands
    check_requirements
    
    # Load configuration
    load_configuration
    
    return 0
}

# Additional repository setup
setup_repository() {
    local repo_dir="$(pwd)"
    
    log_message "DEBUG" "Performing additional repository setup..."
    
    # Check if there's a setup script
    if [ -f "${repo_dir}/setup.sh" ]; then
        log_message "INFO" "Found setup.sh, executing..."
        
        if (cd "$repo_dir" && chmod +x setup.sh && ./setup.sh 2>&1 | tee -a "$LOG_FILE"); then
            log_message "SUCCESS" "Repository setup script executed successfully"
        else
            log_message "WARNING" "Repository setup script failed or had warnings"
        fi
    fi
    
    # Check for README
    local readme_file=$(find "$repo_dir" -maxdepth 1 -iname "readme*" | head -1)
    if [ -n "$readme_file" ] && [ "$VERBOSITY" -ge 4 ]; then
        log_message "DEBUG" "Repository has README: $(basename "$readme_file")"
    fi
}

# ============================================
# FINAL SUMMARY FUNCTION
# ============================================

# Generate comprehensive final summary report
generate_final_summary() {
    local summary_separator="================================================================================"
    local separator_length=${#summary_separator}
    
    # Add blank line before summary for separation
    if [ -t 2 ] && [ "$VERBOSITY" -ge 2 ]; then
        printf "\n"
    fi

    log_message "INFO" "$summary_separator"
    log_message "INFO" "                        - EXECUTION SUMMARY"
    log_message "INFO" "$summary_separator"
    
    # Basic script info
    log_message "INFO" "SCRIPT EXECUTION DETAILS:"
    log_message "INFO" "  Script Name:    ${SCRIPT_NAME}"
    log_message "INFO" "  Executed by:    $(whoami)"
    log_message "INFO" "  Execution Time: $(date '+%Y-%m-%d %H:%M:%S %Z')"
    log_message "INFO" "  Script Version: 1.0"
    log_message "INFO" "  OS Type:        ${OS_TYPE:-unknown}"
    log_message "INFO" ""
    log_message "INFO" ""
    log_message "INFO" ""
    
    # Logging info
    log_message "INFO" "LOGGING INFORMATION:"
    log_message "INFO" "  Main Log File:  ${LOG_FILE}"
    log_message "INFO" "  Error Log:      ${ERROR_LOG_FILE}"
    log_message "INFO" "  Log Directory:  ${LOG_DIR}"
    log_message "INFO" "  Verbosity:      Level ${VERBOSITY} ($(get_verbosity_description))"
    log_message "INFO" ""
    
    # System info (debug mode only)
    if [ "$VERBOSITY" -ge 4 ]; then
        log_message "DEBUG" "SYSTEM INFORMATION:"
        log_message "DEBUG" "  Bash Version:   ${BASH_VERSION}"
        log_message "DEBUG" "  Git Version:    $(git --version 2>/dev/null || echo "Not available")"
        log_message "DEBUG" "  Disk Usage:     $(df -h "$CLONE_DIR" 2>/dev/null | tail -1 || echo "Not available")"
        log_message "DEBUG" ""
    fi
    
    log_message "INFO" "$summary_separator"
    
    # Reminder for next steps (info mode and above)
    if [ "$VERBOSITY" -ge 2 ]; then
        log_message "INFO" "NEXT STEPS:"
        log_message "INFO" "  1. "
        log_message "INFO" "  2. "
        log_message "INFO" "  3. "
        
        if [ -f "${CONFIG_FILE}.example" ] && [ ! -f "$CONFIG_FILE" ]; then
            log_message "INFO" "  4. Customize settings by copying: ${CONFIG_FILE}.example -> ${CONFIG_FILE}"
        fi
        
        log_message "INFO" ""
    fi
    
    # Final timing note
    log_message "INFO" "Script execution completed at: $(date '+%H:%M:%S')"
    log_message "INFO" "$summary_separator"
    
    return 0
}

# ============================================
# MAIN EXECUTION
# ============================================

main() {
    # Initialize logging (from logging.sh)
    if ! init_logging; then
        echo "ERROR: Failed to initialize logging system"
        exit 1
    fi

    # Set verbosity in logging module before initialization
    set_verbosity "$VERBOSITY"
    
    
    # Setup error traps (from logging.sh)
    setup_traps
    
    # Log script start with verbosity info
    if [ "$VERBOSITY" -ge 4 ]; then
        log_message "DEBUG" "Verbosity level: $VERBOSITY ($(get_verbosity_description))"
    fi
    
    # Initialize the setup
    if ! initialize_setup; then
        log_message "ERROR" "Initialization failed"
        exit 1
    fi
    
    # Scan current folder
    scan_current_folder
    
    # setup repositories
    if ! setup_repository; then
        log_message "WARNING" "Some repositories failed to clone"
    fi
    
    # Final summary
    generate_final_summary
    
}

# Run main function
main "$@"