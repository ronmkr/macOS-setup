#!/usr/bin/env bash

set -euo pipefail

# Script version
readonly VERSION="1.0.0"

# Define paths
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly INSTALL_DIR="/usr/local/lib/macos-setup"
readonly BIN_DIR="/usr/local/bin"
readonly CONFIG_DIR="/usr/local/etc/macos-setup"
readonly BACKUP_DIR="/usr/local/var/macos-setup/backups"
readonly LOG_DIR="/usr/local/var/log/macos-setup"
readonly TEMPLATE_DIR="$SCRIPT_DIR/templates"

# Load message templates
if [[ -f "$TEMPLATE_DIR/errors.txt.template" ]]; then
    source "$TEMPLATE_DIR/errors.txt.template"
fi

if [[ -f "$TEMPLATE_DIR/install_messages.txt.template" ]]; then
    source "$TEMPLATE_DIR/install_messages.txt.template"
fi

# Color codes
readonly CYAN='\033[0;36m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

# Required commands
readonly REQUIRED_COMMANDS=(
  "basename"
  "cp"
  "mkdir"
  "chmod"
  "chown"
  "ln"
  "rm"
  "touch"
)

# Print functions
print_status()   { printf "%b%s%b\n" "${CYAN}"   "$1" "${NC}"; }
print_success()  { printf "%b%s%b\n" "${GREEN}"  "$1" "${NC}"; }
print_warning()  { printf "%b%s%b\n" "${YELLOW}" "$1" "${NC}"; }
print_error()    { printf "%b%s%b\n" "${RED}"    "$1" "${NC}" >&2; }

# Utility functions
check_command() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || {
    print_error "Required command not found: $cmd"
    exit 1
  }
}

check_dependencies() {
  print_status "Checking dependencies..."
  for cmd in "${REQUIRED_COMMANDS[@]}"; do
    check_command "$cmd"
  done
}

backup_existing() {
  local target="$1"
  if [[ -e "$target" ]]; then
    local backup="${target}.bak.$(date +%Y%m%d_%H%M%S)"
    print_warning "Backing up existing installation: $target -> $backup"
    mv "$target" "$backup"
  fi
}

create_directories() {
  print_status "Creating required directories..."
  for dir in \
    "$INSTALL_DIR" \
    "$CONFIG_DIR" \
    "$BACKUP_DIR" \
    "$LOG_DIR" \
    "$INSTALL_DIR/lib" \
    "$INSTALL_DIR/modules" \
    "$INSTALL_DIR/templates"
  do
    if [[ ! -d "$dir" ]]; then
      mkdir -p "$dir"
      chmod 755 "$dir"
    fi
  done
}

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
  print_error "This script must be run with sudo"
  exit 1
fi

# Check macOS
if [[ "$(uname)" != "Darwin" ]]; then
  print_error "This script is only for macOS"
  exit 1
fi

# Main installation function
install_script() {
  # Check dependencies first
  check_dependencies

  # Create directory structure
  create_directories

  # Backup existing installation
  backup_existing "$INSTALL_DIR"
  backup_existing "$BIN_DIR/macos-setup"

  # Copy files
  print_status "Copying files..."
  cp "$SCRIPT_DIR/macos-setup" "$INSTALL_DIR/"
  cp -r "$SCRIPT_DIR/lib/"* "$INSTALL_DIR/lib/"
  cp -r "$SCRIPT_DIR/modules/"* "$INSTALL_DIR/modules/"
  cp -r "$SCRIPT_DIR/templates/"* "$INSTALL_DIR/templates/"

  # Handle configuration
  print_status "${MSG_CONFIG_SETUP}"
  if [[ ! -f "$CONFIG_DIR/config.sh" ]]; then
    if [[ -f "$TEMPLATE_DIR/config.sh.template" ]]; then
      cp "$TEMPLATE_DIR/config.sh.template" "$CONFIG_DIR/config.sh"
      chmod 644 "$CONFIG_DIR/config.sh"
      print_success "${MSG_CONFIG_CREATED}"
    else
      print_error "${E_CONFIG_FAILED}"
      exit 1
    fi
  else
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_path="$CONFIG_DIR/config.sh.backup-$timestamp"
    print_warning "${MSG_CONFIG_EXISTS}"
    cp "$CONFIG_DIR/config.sh" "$backup_path"
    if [[ -f "$TEMPLATE_DIR/config.sh.template" ]]; then
      # Merge new template with existing config
      awk '
        FNR==NR { if ($0 ~ /^[A-Z_]+=/) { a[$1]=$0 }; next }
        $0 ~ /^[A-Z_]+=/ { if (!($1 in a)) print; next }
        { print }
      ' "$CONFIG_DIR/config.sh" "$TEMPLATE_DIR/config.sh.template" > "$CONFIG_DIR/config.sh.new"
      mv "$CONFIG_DIR/config.sh.new" "$CONFIG_DIR/config.sh"
      chmod 644 "$CONFIG_DIR/config.sh"
    fi
  fi

  # Set permissions
  print_status "${MSG_SETTING_PERMS}"

  # Set directory permissions
  find "$INSTALL_DIR" -type d -exec chmod 755 {} \; || {
    print_error "${E_PERM_FAILED}" "directories"
    exit 1
  }

  # Set file permissions
  find "$INSTALL_DIR" -type f -name "*.sh" -exec chmod 644 {} \; || {
    print_error "${E_PERM_FAILED}" "script files"
    exit 1
  }

  # Set executable permissions
  chmod 755 "$INSTALL_DIR/macos-setup" || {
    print_error "${E_PERM_FAILED}" "main script"
    exit 1
  }

  # Set config file permissions
  chmod 644 "$CONFIG_DIR/config.sh" || {
    print_error "${E_PERM_FAILED}" "config file"
    exit 1
  }

  # Set template permissions
  find "$INSTALL_DIR/templates" -type f -exec chmod 644 {} \; || {
    print_error "${E_PERM_FAILED}" "templates"
    exit 1
  }

  # Set ownership
  print_status "Setting ownership..."
  chown -R root:wheel "$INSTALL_DIR" "$CONFIG_DIR"
  chmod 755 "$INSTALL_DIR" "$CONFIG_DIR"

  # Create symlink
  print_status "Creating symlink..."
  ln -sf "$INSTALL_DIR/macos-setup" "$BIN_DIR/macos-setup"

  # Create log rotation configuration
  if [[ ! -f "/etc/newsyslog.d/macos-setup.conf" ]]; then
    print_status "Setting up log rotation..."
    # Read template and replace placeholders
    sed "s|%logpath%|$LOG_DIR|g" "$SCRIPT_DIR/templates/newsyslog.conf.template" \
      > "/etc/newsyslog.d/macos-setup.conf"
    chmod 644 "/etc/newsyslog.d/macos-setup.conf"
    print_success "Log rotation configured"
  fi

  # Verify installation
  print_status "Verifying installation..."
  if ! command -v macos-setup &>/dev/null; then
    print_error "Installation verification failed"
    exit 1
  fi

  print_success "Installation complete! Version $VERSION"
  print_status "Configuration file: $CONFIG_DIR/config.sh"
  print_status "Logs directory: $LOG_DIR"
  print_status "Try 'macos-setup --help' for usage information"
}

# Run installation
install_script