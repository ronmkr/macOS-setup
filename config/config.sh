#!/usr/bin/env bash

###############################################################################
# General Settings                                                             #
###############################################################################

# Version
readonly CONFIG_VERSION="1.0.0"

# Default options
readonly DEFAULT_BACKUP=true           # Always create backups by default
readonly DEFAULT_VERBOSE=false         # Minimal output by default
readonly DEFAULT_FORCE=false          # Don't force operations by default
readonly DEFAULT_NO_RESTART=false     # Allow restarts by default
readonly DEFAULT_DRY_RUN=false       # Actually perform operations by default
readonly DEFAULT_SILENT=false        # Show normal output by default

# Directory paths
readonly SCREENSHOTS_DIR="${HOME}/Desktop/Screenshots"
readonly DOWNLOADS_DIR="${HOME}/Downloads"
readonly BACKUP_BASE_DIR="${HOME}/.local/share/macos-setup/backups"
readonly CACHE_DIR="${HOME}/.cache/macos-setup"

# Retention settings
readonly BACKUP_RETENTION_COUNT=5      # Number of backups to keep
readonly DOWNLOADS_CLEANUP_DAYS=30     # Remove downloads older than this
readonly LOG_RETENTION_DAYS=7         # Keep logs for this many days
readonly CACHE_RETENTION_DAYS=3       # Keep cache files for this many days

###############################################################################
# Module Settings                                                              #
###############################################################################

# Finder settings
readonly FINDER_SETTINGS=(
    SHOW_ALL_FILES=true
    SHOW_PATH_BAR=true
    SHOW_STATUS_BAR=true
    SHOW_PREVIEW_PANE=true
    DEFAULT_VIEW="clmv"              # Icon=icnv, List=Nlsv, Column=clmv, Gallery=glyv
)

# Dock settings
readonly DOCK_SETTINGS=(
    AUTOHIDE=true
    MAGNIFICATION=true
    MINIMIZE_TO_APP=true
    SHOW_RECENT=false
    ICON_SIZE=36
    MAGNIFIED_SIZE=64
)

# Terminal settings
readonly TERMINAL_SETTINGS=(
    THEME="Pro"
    FONT_SIZE=12
    FONT_NAME="SFMono-Regular"
    SCROLLBACK_LINES=10000
    SECURE_KEYBOARD=true
)

# Safari settings
readonly SAFARI_SETTINGS=(
    SHOW_FULL_URL=true
    SHOW_DEV_MENU=true
    ENABLE_AUTOFILL=false
    ENABLE_PLUGINS=false
    ENABLE_JAVA=false
)

###############################################################################
# Cleanup Settings                                                            #
###############################################################################

# Cleanup thresholds
readonly CLEANUP_SETTINGS=(
    MIN_FREE_SPACE=10                # Minimum free space in GB
    OLD_FILE_DAYS=90                # Files older than this are "old"
    CACHE_SIZE_LIMIT=1024           # Cache size limit in MB
)

# File patterns to clean
readonly CLEANUP_PATTERNS=(
    "*.log"
    "*.tmp"
    "*.old"
    "*.bak"
    "*.cache"
)

# Directories to exclude from cleanup
readonly CLEANUP_EXCLUDES=(
    "${HOME}/Documents"
    "${HOME}/Pictures"
    "${HOME}/Music"
    "${HOME}/Movies"
    "${HOME}/.ssh"
    "${HOME}/.gnupg"
)

###############################################################################
# Security Settings                                                           #
###############################################################################

# Security options
readonly SECURITY_SETTINGS=(
    FIREWALL_ENABLED=true
    FIREWALL_STEALTH_MODE=true
    FILEVAULT_ENABLED=true
    REQUIRE_PASSWORD_DELAY=0         # Require password immediately
    SECURE_KEYBOARD_ENTRY=true
)

# SSL/TLS settings
readonly SSL_SETTINGS=(
    MIN_TLS_VERSION="1.2"
    VERIFY_CERTIFICATES=true
    OCSP_ENABLED=true
)

###############################################################################
# Performance Settings                                                        #
###############################################################################

# System performance
readonly PERFORMANCE_SETTINGS=(
    DISABLE_ANIMATIONS=true
    REDUCE_TRANSPARENCY=true
    REDUCE_MOTION=true
    DISABLE_SUDDEN_MOTION=true
)

# Memory management
readonly MEMORY_SETTINGS=(
    PURGE_MEMORY_DAYS=7             # Days between automatic memory purge
    SWAP_FILE_SIZE=8                # Swap file size in GB
    HIBERNATE_MODE=3                # 0=no hibernate, 3=safe hibernate
)