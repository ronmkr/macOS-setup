#!/usr/bin/env bash

setup_backup() {
    print_status "Creating backup of current settings..."
    log_info "Starting system settings backup"

    # Create timestamped backup directory
    local backup_dir="${HOME}/.local/share/macos-setup/backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"

    # Array of domains to backup
    local domains=(
        "com.apple.finder"
        "com.apple.dock"
        "NSGlobalDomain"
        "com.apple.Safari"
        "com.apple.terminal"
        "com.apple.screensaver"
        "com.apple.screencapture"
        "com.apple.menuextra.clock"
        "com.apple.driver.AppleBluetoothMultitouch.trackpad"
        "com.apple.AppleMultitouchTrackpad"
        "com.apple.driver.AppleIRController"
        "com.apple.loginwindow"
        "com.apple.mail"
        "com.apple.universalaccess"
    )

    # Backup each domain
    for domain in "${domains[@]}"; do
        local filename
        filename=$(echo "$domain" | sed 's/^com\.apple\.//' | tr '.' '-')
        print_status "Backing up $domain..."

        # Try both text and binary formats
        if ! defaults export "$domain" "$backup_dir/$filename.binary.plist" 2>/dev/null; then
            log_warning "Failed to export binary plist for $domain"
        fi

        if ! defaults read "$domain" > "$backup_dir/$filename.text.plist" 2>/dev/null; then
            log_warning "Failed to read text plist for $domain"
        fi
    done

    # Backup system preferences that require root
    if is_sudo; then
        print_status "Backing up root-level settings..."

        local root_domains=(
            "/Library/Preferences/com.apple.alf"              # Firewall
            "/Library/Preferences/SystemConfiguration"        # Network
            "/Library/Preferences/.GlobalPreferences.plist"  # System globals
        )

        for domain in "${root_domains[@]}"; do
            local filename
            filename=$(basename "$domain" | sed 's/\.plist$//')
            sudo cp -R "$domain" "$backup_dir/root-$filename.plist" 2>/dev/null || \
                log_warning "Failed to backup $domain"
        done
    fi

    # Copy restore script template
    cp "$SCRIPT_DIR/templates/restore.sh.template" "$backup_dir/restore.sh"

    chmod +x "$backup_dir/restore.sh"
    print_success "Backup created at: $backup_dir"
    print_status "To restore: cd $backup_dir && ./restore.sh"
}

setup_backup_cleanup() {
    print_status "Performing backup cleanup..."

    # Get backup directory
    local backup_base_dir="${HOME}/.local/share/macos-setup/backups"

    # Keep only the last 5 backups
    if [[ -d "$backup_base_dir" ]]; then
        local backup_count
        backup_count=$(find "$backup_base_dir" -mindepth 1 -maxdepth 1 -type d | wc -l)

        if ((backup_count > 5)); then
            print_status "Cleaning up old backups..."
            find "$backup_base_dir" -mindepth 1 -maxdepth 1 -type d | \
                sort | \
                head -n -5 | \
                xargs rm -rf

            log_info "Removed $(($backup_count - 5)) old backup(s)"
        fi
    fi
}