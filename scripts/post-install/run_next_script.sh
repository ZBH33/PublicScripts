# ============================================================================
# FUNCTION: run_next_script
# ============================================================================
# Safely executes another script after the current one finishes.
# Intended to be called as the FINAL action of a script.
#
# Behavior:
# - Verifies the next script exists and is executable
# - Executes it in a new process
# - Exits the current script with the same exit code
# ============================================================================

run_next_script() {
    local next_script="$1"

    # Ensure a target script was provided
    if [ -z "$next_script" ]; then
        echo "ERROR: No next script specified to run_next_script()" >&2
        return 1
    fi

    # Ensure the script exists
    if [ ! -f "$next_script" ]; then
        echo "ERROR: Next script not found: $next_script" >&2
        return 1
    fi

    # Ensure the script is executable
    if [ ! -x "$next_script" ]; then
        echo "ERROR: Next script is not executable: $next_script" >&2
        return 1
    fi

    echo "INFO: Handing off execution to: $next_script"

    # Execute the next script
    "$next_script"

    # Capture its exit code
    exit_code="$?"

    # Exit the current script with the same status
    exit "$exit_code"
}
