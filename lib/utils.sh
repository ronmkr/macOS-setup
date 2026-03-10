#!/usr/bin/env bash

# Colors
readonly CYAN='\033[0;36m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

# Global Variables (set by main script)
DRY_RUN=${DRY_RUN:-false}
VERBOSE=${VERBOSE:-false}

# User context detection
if [[ -n "${SUDO_USER:-}" ]]; then
    USER_NAME="${SUDO_USER}"
    USER_HOME=$(eval echo "~${SUDO_USER}")
else
    USER_NAME=$(whoami)
    USER_HOME="${HOME}"
fi

# Print functions
print_status()  { printf "%b%s%b\n" "${CYAN}" "$1" "${NC}"; }
print_success() { printf "%b%s%b\n" "${GREEN}" "$1" "${NC}"; }
print_warning() { printf "%b%s%b\n" "${YELLOW}" "$1" "${NC}"; }
print_error()   { printf "%b%s%b\n" "${RED}" "$1" "${NC}" >&2; }

# Show a native macOS notification
show_notification() {
    local title="$1"
    local message="$2"
    if [[ "$DRY_RUN" == "false" ]]; then
        # Must run as user to show notification on their desktop
        sudo -u "${USER_NAME}" osascript -e "display notification \"$message\" with title \"$title\" sound name \"Crystal\""
    fi
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ensure running with sudo
ensure_sudo() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run with sudo privileges"
        exit 1
    fi
}

# Keep sudo alive in the background
keep_sudo_alive() {
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done 2>/dev/null &
}

# Restart specific application
restart_app() {
    local app="$1"
    if pgrep -x "$app" >/dev/null; then
        if [[ "$DRY_RUN" == "true" ]]; then
            print_status "[DRY-RUN] Would restart $app"
            return
        fi
        print_status "Restarting $app..."
        killall "$app" &>/dev/null || true
    fi
}

# Execute defaults write with idempotency and user-awareness
defaults_write() {
    local domain="$1"
    local key="$2"
    local value="$3"
    local type="$4"
    local current_val
    
    local cmd_prefix=""
    if [[ "$domain" != "/Library"* && "$domain" != "/System"* ]]; then
        cmd_prefix="sudo -u ${USER_NAME}"
    fi

    current_val=$($cmd_prefix defaults read "$domain" "$key" 2>/dev/null || echo "NOT_SET")
    
    if [[ "$current_val" == "$value" ]]; then
        [[ "$VERBOSE" == "true" ]] && print_status "  - $key already set to $value"
        return 0
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        print_status "[DRY-RUN] Would write: $domain $key -> $value"
        return 0
    fi

    if [[ -n "$type" ]]; then
        $cmd_prefix defaults write "$domain" "$key" -"$type" "$value" || \
            print_error "Failed to write: $domain $key"
    else
        $cmd_prefix defaults write "$domain" "$key" "$value" || \
            print_error "Failed to write: $domain $key"
    fi
}

# Check if feature is enabled in config
is_feature_enabled() {
    local feature="$1"
    [[ " ${ENABLED_FEATURES[*]} " == *" $feature "* ]]
}
