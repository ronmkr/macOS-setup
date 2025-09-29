#!/usr/bin/env bash

# Log file location
readonly LOG_DIR="${HOME}/.local/share/macos-setup/logs"
readonly LOG_FILE="${LOG_DIR}/$(date +%Y%m%d_%H%M%S).log"

setup_logging() {
    # Create log directory
    mkdir -p "$LOG_DIR"

    # Start logging
    exec 3>&1 4>&2
    trap 'exec 1>&3 2>&4' EXIT
    exec 1> >(tee -a "$LOG_FILE") 2>&1

    # Log system information
    {
        echo "macOS Setup Log - $(date)"
        echo "======================="
        echo "System Info:"
        echo "- macOS Version: $(sw_vers -productVersion)"
        echo "- Host Name: $(hostname)"
        echo "- User: $(whoami)"
        echo "- Admin Rights: $(is_sudo && echo "Yes" || echo "No")"
        echo "======================="
    } >> "$LOG_FILE"
}

log_success() {
    echo "[SUCCESS] $(date +%H:%M:%S) - $1" >> "$LOG_FILE"
}

log_error() {
    echo "[ERROR] $(date +%H:%M:%S) - $1" >> "$LOG_FILE"
}

log_warning() {
    echo "[WARNING] $(date +%H:%M:%S) - $1" >> "$LOG_FILE"
}

log_info() {
    echo "[INFO] $(date +%H:%M:%S) - $1" >> "$LOG_FILE"
}