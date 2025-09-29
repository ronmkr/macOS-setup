#!/usr/bin/env bash

# Colors
readonly CYAN='\033[0;36m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

# Print functions
print_status() {
    printf "%b%s%b\n" "${CYAN}" "$1" "${NC}"
}

print_success() {
    printf "%b%s%b\n" "${GREEN}" "$1" "${NC}"
}

print_warning() {
    printf "%b%s%b\n" "${YELLOW}" "$1" "${NC}"
}

print_error() {
    printf "%b%s%b\n" "${RED}" "$1" "${NC}" >&2
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if running with sudo
is_sudo() {
    [[ $EUID -eq 0 ]]
}

# Ensure running with sudo
ensure_sudo() {
    if ! is_sudo; then
        print_error "This script must be run with sudo privileges"
        exit 1
    fi
}

# Keep sudo alive
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
        print_status "Restarting $app..."
        killall "$app" 2>/dev/null
    fi
}

# Execute defaults write with error handling
defaults_write() {
    local domain="$1"
    local key="$2"
    local value="$3"
    local type="$4"

    if [[ -n "$type" ]]; then
        defaults write "$domain" "$key" -"$type" "$value" 2>/dev/null || \
            print_error "Failed to write: $domain $key"
    else
        defaults write "$domain" "$key" "$value" 2>/dev/null || \
            print_error "Failed to write: $domain $key"
    fi
}

# Check if feature is enabled in config
is_feature_enabled() {
    local feature="$1"
    [[ " ${ENABLED_FEATURES[*]} " == *" $feature "* ]]
}