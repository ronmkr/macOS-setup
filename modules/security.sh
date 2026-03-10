#!/usr/bin/env bash

setup_security() {
    print_status "Configuring security settings..."
    log_info "Starting security configuration"

    # Screen security
    print_status "Configuring screen security..."
    defaults_write "com.apple.screensaver" "askForPassword" "1" "int"
    defaults_write "com.apple.screensaver" "askForPasswordDelay" "0" "float"
    defaults_write "com.apple.screensaver" "idleTime" "300" "int"  # 5 minutes
    defaults_write "NSGlobalDomain" "com.apple.screensaver.preferences.autostartAfter" "300" "int"

    # Firewall configuration
    print_status "Configuring firewall..."
    # Enable firewall
    defaults_write "/Library/Preferences/com.apple.alf" "globalstate" "1" "int"
    defaults_write "/Library/Preferences/com.apple.alf" "allowsignedenabled" "1" "int"
    defaults_write "/Library/Preferences/com.apple.alf" "stealthenabled" "1" "int"

    # Block all incoming connections
    defaults_write "/Library/Preferences/com.apple.alf" "allowdownloadsignedenabled" "1" "int"
    defaults_write "/Library/Preferences/com.apple.alf" "loggingenabled" "1" "int"

    # Enable logging
    defaults_write "/Library/Preferences/com.apple.alf" "loggingoption" "2" "int"

    # FileVault disk encryption
    print_status "Configuring disk encryption..."
    if ! fdesetup isactive >/dev/null; then
        print_warning "FileVault is not active!"
        if [[ "$DRY_RUN" == "true" ]]; then
            print_status "[DRY-RUN] Would prompt to enable FileVault"
        else
            print_status "Enabling FileVault (requires user password)..."
            # We don't use defaults_write here as fdesetup is interactive
            sudo fdesetup enable -user "${USER_NAME}" || \
                print_error "Failed to enable FileVault. This usually requires manual interaction."
        fi
    fi

    # Enable secure virtual memory
    defaults_write "/Library/Preferences/com.apple.virtualMemory" "UseEncryptedSwap" "true" "bool"

    # Login window and account security
    print_status "Configuring login security..."
    # Disable guest account
    defaults_write "/Library/Preferences/com.apple.loginwindow" "GuestEnabled" "0" "bool"
    
    # Disable automatic login
    defaults_write "/Library/Preferences/com.apple.loginwindow" "autoLoginUser" "0" "bool"

    # Display login window as name and password
    defaults_write "/Library/Preferences/com.apple.loginwindow" "SHOWFULLNAME" "1" "bool"

    # Show administrator contact info on lock screen
    defaults_write "/Library/Preferences/com.apple.loginwindow" "LoginwindowText" "Contact IT Support"

    # Disable IR remote control
    print_status "Configuring hardware security..."
    defaults_write "/Library/Preferences/com.apple.driver.AppleIRController" "DeviceEnabled" "0" "bool"

    # Safari security (if installed)
    if [[ -d "/Applications/Safari.app" ]]; then
        print_status "Configuring Safari security..."
        defaults_write "com.apple.Safari" "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled" "0" "bool"
        defaults_write "com.apple.Safari" "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles" "0" "bool"
    fi

    # Time Machine encryption
    print_status "Configuring backup security..."
    defaults_write "/Library/Preferences/com.apple.TimeMachine" "RequiresEncryption" "1" "bool"

    # System Integrity Protection
    print_status "Checking System Integrity Protection..."
    if ! csrutil status | grep -q "enabled"; then
        print_warning "System Integrity Protection is not enabled. Enable it by booting into Recovery Mode"
        log_warning "System Integrity Protection is disabled"
    fi

    print_success "Security settings applied"
    log_info "Security configuration completed"
}

setup_security_cleanup() {
    print_status "Performing security cleanup..."
    log_info "Starting security cleanup"

    if [[ "$DRY_RUN" == "true" ]]; then
        print_status "[DRY-RUN] Would perform security cleanup"
        return
    fi

    # Flush security-related caches
    sudo pkill -HUP "socketfilterfw" &>/dev/null || true

    # Remove potentially sensitive temporary files
    sudo rm -rf /private/tmp/* 2>/dev/null || true
    sudo rm -rf /private/var/tmp/* 2>/dev/null || true

    # Clear audit logs older than 30 days
    sudo find /var/audit -type f -mtime +30 -delete 2>/dev/null || true

    # Clear system logs older than 7 days
    sudo find /var/log -type f -mtime +7 -delete 2>/dev/null || true

    print_success "Security cleanup completed"
    log_info "Security cleanup finished"
}
