#!/usr/bin/env bash

setup_system() {
    print_status "Configuring system settings..."
    log_info "Starting system configuration"

    # Screenshots and screen recording
    print_status "Configuring screen capture settings..."
    local screenshots_dir="${HOME}/Desktop/Screenshots"
    mkdir -p "$screenshots_dir"
    defaults_write "com.apple.screencapture" "location" "$screenshots_dir"
    defaults_write "com.apple.screencapture" "type" "png"
    defaults_write "com.apple.screencapture" "disable-shadow" "true" "bool"
    defaults_write "com.apple.screencapture" "show-thumbnail" "false" "bool"
    defaults_write "com.apple.screencapture" "include-date" "true" "bool"
    defaults_write "com.apple.screencapture" "showsCursor" "true" "bool"
    defaults_write "com.apple.screencapture" "preservation-mode" "true" "bool"

    # System appearance and behavior
    print_status "Configuring system appearance..."
    # Animations and effects
    defaults_write "NSGlobalDomain" "NSAutomaticWindowAnimationsEnabled" "false" "bool"
    defaults_write "NSGlobalDomain" "NSWindowResizeTime" "0.001"
    defaults_write "NSGlobalDomain" "NSScrollAnimationEnabled" "false" "bool"
    defaults_write "com.apple.universalaccess" "reduceTransparency" "true" "bool"
    defaults_write "com.apple.universalaccess" "reduceMotion" "true" "bool"
    defaults_write "NSGlobalDomain" "AppleInterfaceStyle" "Dark"  # Dark mode
    defaults_write "NSGlobalDomain" "AppleAccentColor" "-1"  # Blue
    defaults_write "NSGlobalDomain" "AppleHighlightColor" "0.968627 0.831373 1.000000 Purple"

    # Sound and audio
    print_status "Configuring sound settings..."
    defaults_write "NSGlobalDomain" "com.apple.sound.beep.feedback" "0" "bool"
    defaults_write "com.apple.systemsound" "com.apple.sound.uiaudio.enabled" "0" "bool"
    defaults_write "NSGlobalDomain" "com.apple.sound.beep.volume" "0.0"
    defaults_write "com.apple.sound.beep" "volume" "0.0"
    defaults_write "com.apple.systemsound" "com.apple.sound.beep.flash" "0"

    # Menu bar customization
    print_status "Configuring menu bar..."
    defaults_write "NSGlobalDomain" "_HIHideMenuBar" "true" "bool"
    defaults_write "com.apple.menuextra.clock" "DateFormat" "EEE MMM d  H:mm"
    defaults_write "com.apple.menuextra.clock" "ShowSeconds" "true" "bool"
    defaults_write "com.apple.menuextra.battery" "ShowPercent" "true" "bool"

    # Menu bar items
    defaults_write "com.apple.systemuiserver" "menuExtras" -array \
        "/System/Library/CoreServices/Menu Extras/Clock.menu" \
        "/System/Library/CoreServices/Menu Extras/Battery.menu" \
        "/System/Library/CoreServices/Menu Extras/Volume.menu" \
        "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
        "/System/Library/CoreServices/Menu Extras/AirPort.menu"

    # Font and text rendering
    print_status "Configuring font settings..."
    defaults_write "NSGlobalDomain" "AppleFontSmoothing" "2"
    defaults_write "NSGlobalDomain" "CGFontRenderingFontSmoothingDisabled" "false" "bool"
    defaults_write "NSGlobalDomain" "AppleAntiAliasingThreshold" "4"
    defaults_write "NSGlobalDomain" "AppleAquaColorVariant" "1"
    defaults_write "NSGlobalDomain" "AppleShowAllExtensions" "true" "bool"

    # Power management
    print_status "Configuring power management..."
    if is_sudo; then
        # AC Power settings
        sudo pmset -c sleep 0
        sudo pmset -c disksleep 0
        sudo pmset -c displaysleep 15
        sudo pmset -c hibernatemode 0
        sudo pmset -c womp 1  # Wake on LAN

        # Battery settings
        sudo pmset -b sleep 15
        sudo pmset -b disksleep 10
        sudo pmset -b displaysleep 5
        sudo pmset -b hibernatemode 3

        # Common settings
        sudo pmset -a standbydelay 86400
        sudo pmset -a powernap 0
        sudo pmset -a lidwake 1
        sudo pmset -a autorestart 1
    fi

    # Spotlight configuration
    print_status "Configuring Spotlight..."
    if is_sudo; then
        # Disable indexing for external volumes
        sudo defaults write "/.Spotlight-V100/VolumeConfiguration" "Exclusions" -array "/Volumes"

        # Configure search categories
        defaults write "com.apple.spotlight" "orderedItems" -array \
            '{"enabled" = 1; "name" = "APPLICATIONS";}' \
            '{"enabled" = 1; "name" = "SYSTEM_PREFS";}' \
            '{"enabled" = 1; "name" = "DIRECTORIES";}' \
            '{"enabled" = 1; "name" = "PDF";}' \
            '{"enabled" = 0; "name" = "FONTS";}' \
            '{"enabled" = 0; "name" = "DOCUMENTS";}' \
            '{"enabled" = 0; "name" = "MESSAGES";}' \
            '{"enabled" = 0; "name" = "CONTACT";}' \
            '{"enabled" = 0; "name" = "EVENT_TODO";}' \
            '{"enabled" = 0; "name" = "IMAGES";}' \
            '{"enabled" = 0; "name" = "BOOKMARKS";}' \
            '{"enabled" = 0; "name" = "MUSIC";}' \
            '{"enabled" = 0; "name" = "MOVIES";}' \
            '{"enabled" = 0; "name" = "PRESENTATIONS";}' \
            '{"enabled" = 0; "name" = "SPREADSHEETS";}' \
            '{"enabled" = 0; "name" = "SOURCE";}'

        # Clean up and reindex
        sudo mdutil -i off "/Volumes/*"
        sudo mdutil -E "/"
    fi

    # System maintenance
    print_status "Configuring system maintenance..."
    if is_sudo; then
        # Set up periodic maintenance scripts
        sudo defaults write "/System/Library/LaunchDaemons/com.apple.periodic-daily.plist" "StartCalendarInterval" -dict Hour 3 Minute 0
        sudo defaults write "/System/Library/LaunchDaemons/com.apple.periodic-weekly.plist" "StartCalendarInterval" -dict Hour 4 Minute 0 Weekday 0
        sudo defaults write "/System/Library/LaunchDaemons/com.apple.periodic-monthly.plist" "StartCalendarInterval" -dict Hour 5 Minute 0 Day 1

        # Log rotation
        sudo newsyslog -n  # Force immediate log rotation

        # Remove old logs
        find /var/log -type f \( -name "*.log" -o -name "*.old" -o -name "*.err" \) \
            -mtime +30 -exec rm -f {} \; 2>/dev/null || true
    fi

    # Crash reporter
    defaults_write "com.apple.CrashReporter" "DialogType" "none"

    # Save panel expansion
    defaults_write "NSGlobalDomain" "NSNavPanelExpandedStateForSaveMode" "true" "bool"
    defaults_write "NSGlobalDomain" "NSNavPanelExpandedStateForSaveMode2" "true" "bool"

    # Print panel expansion
    defaults_write "NSGlobalDomain" "PMPrintingExpandedStateForPrint" "true" "bool"
    defaults_write "NSGlobalDomain" "PMPrintingExpandedStateForPrint2" "true" "bool"

    print_success "System settings applied"
    log_info "System configuration completed"
}

setup_system_cleanup() {
    print_status "Performing system cleanup..."
    log_info "Starting system cleanup"

    # Restart system services
    if is_sudo; then
        # Restart Spotlight
        sudo killall mds > /dev/null 2>&1 || true

        # Restart UI server
        sudo killall SystemUIServer > /dev/null 2>&1 || true

        # Clear system caches
        sudo rm -rf /Library/Caches/* 2>/dev/null || true
        sudo rm -rf /System/Library/Caches/* 2>/dev/null || true

        # Clear font caches
        sudo atsutil databases -remove

        # Clear DNS cache
        sudo dscacheutil -flushcache
        sudo killall -HUP mDNSResponder

        # Clear Quick Look cache
        qlmanage -r cache

        # Clear saved application states
        rm -rf ~/Library/Saved\ Application\ State/* 2>/dev/null || true
    fi

    # User-level cleanup
    # Clean Trash
    rm -rf ~/.Trash/* 2>/dev/null || true

    # Clear user caches
    rm -rf ~/Library/Caches/* 2>/dev/null || true

    # Clear temporary files
    rm -rf /private/var/folders/*/*/*/* 2>/dev/null || true

    # Clear QuickLook thumbnails
    rm -rf ~/Library/QuickLook/Thumbnails/* 2>/dev/null || true

    # Clear downloads older than 30 days
    find ~/Downloads -type f -mtime +30 -delete 2>/dev/null || true

    print_success "System cleanup completed"
    log_info "System cleanup finished"

    # Recommend restart
    print_warning "Some changes may require a system restart to take effect"
}