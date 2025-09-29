#!/usr/bin/env bash

setup_input() {
    print_status "Configuring input device settings..."
    log_info "Starting input device configuration"

    # Trackpad settings
    print_status "Configuring trackpad settings..."

    # Basic clicking behavior
    defaults_write "com.apple.driver.AppleBluetoothMultitouch.trackpad" "Clicking" "true" "bool"
    defaults_write "com.apple.AppleMultitouchTrackpad" "Clicking" "true" "bool"
    defaults_write "NSGlobalDomain" "com.apple.mouse.tapBehavior" "1" "int"

    # Secondary click (right-click)
    defaults_write "com.apple.driver.AppleBluetoothMultitouch.trackpad" "TrackpadRightClick" "true" "bool"
    defaults_write "com.apple.AppleMultitouchTrackpad" "TrackpadRightClick" "true" "bool"
    defaults_write "com.apple.driver.AppleBluetoothMultitouch.trackpad" "TrackpadCornerSecondaryClick" "0" "int"

    # Gesture settings
    defaults_write "com.apple.driver.AppleBluetoothMultitouch.trackpad" "TrackpadThreeFingerDrag" "true" "bool"
    defaults_write "com.apple.AppleMultitouchTrackpad" "TrackpadThreeFingerDrag" "true" "bool"
    defaults_write "com.apple.driver.AppleBluetoothMultitouch.trackpad" "TrackpadFourFingerHorizSwipeGesture" "2" "int"
    defaults_write "com.apple.driver.AppleBluetoothMultitouch.trackpad" "TrackpadFourFingerVertSwipeGesture" "2" "int"

    # Tracking speed and sensitivity
    defaults_write "NSGlobalDomain" "com.apple.trackpad.scaling" "1.5" "float"
    defaults_write "NSGlobalDomain" "com.apple.trackpad.forceClick" "true" "bool"

    # Scroll behavior
    defaults_write "NSGlobalDomain" "com.apple.swipescrolldirection" "false" "bool"  # Natural scrolling off
    defaults_write "NSGlobalDomain" "com.apple.trackpad.momentumScroll" "true" "bool"

    # Mouse settings
    print_status "Configuring mouse settings..."
    defaults_write "NSGlobalDomain" "com.apple.mouse.scaling" "3.0" "float"
    defaults_write "NSGlobalDomain" "com.apple.mouse.doubleClickThreshold" "0.5" "float"
    defaults_write "com.apple.AppleMultitouchMouse" "MouseButtonMode" "TwoButton" "string"

    # Keyboard settings
    print_status "Configuring keyboard settings..."

    # Key repeat and delay
    defaults_write "NSGlobalDomain" "KeyRepeat" "2" "int"         # Normal minimum is 2 (30ms)
    defaults_write "NSGlobalDomain" "InitialKeyRepeat" "15" "int" # Normal minimum is 15 (225ms)
    defaults_write "NSGlobalDomain" "ApplePressAndHoldEnabled" "false" "bool"

    # Text behavior
    defaults_write "NSGlobalDomain" "NSAutomaticCapitalizationEnabled" "false" "bool"
    defaults_write "NSGlobalDomain" "NSAutomaticPeriodSubstitutionEnabled" "false" "bool"
    defaults_write "NSGlobalDomain" "NSAutomaticQuoteSubstitutionEnabled" "false" "bool"
    defaults_write "NSGlobalDomain" "NSAutomaticDashSubstitutionEnabled" "false" "bool"
    defaults_write "NSGlobalDomain" "NSAutomaticSpellingCorrectionEnabled" "false" "bool"
    defaults_write "NSGlobalDomain" "NSAutomaticTextCompletionEnabled" "false" "bool"

    # Function key behavior
    defaults_write "NSGlobalDomain" "com.apple.keyboard.fnState" "true" "bool"  # Use F1, F2, etc. as standard function keys

    # Input menu
    defaults_write "com.apple.TextInputMenu" "visible" "true" "bool"
    defaults_write "com.apple.HIToolbox" "AppleCurrentKeyboardLayoutInputSourceID" "com.apple.keylayout.US"

    print_success "Input device settings applied"
}

setup_input_cleanup() {
    print_status "Cleaning up input device settings..."
    log_info "Starting input device cleanup"

    # Reset input method cache
    if is_sudo; then
        sudo rm -rf ~/Library/Preferences/com.apple.HIToolbox.plist* 2>/dev/null || true
    fi

    # Reset trackpad property list cache
    rm -rf ~/Library/Preferences/com.apple.AppleMultitouchTrackpad.plist* 2>/dev/null || true
    rm -rf ~/Library/Preferences/com.apple.driver.AppleBluetoothMultitouch.trackpad.plist* 2>/dev/null || true

    # Kill system input processes to apply changes
    print_status "Applying changes..."
    killall "PressAndHold" 2>/dev/null || true
    killall "SystemUIServer" 2>/dev/null || true

    print_success "Input device cleanup completed"
    log_success "Input device configuration completed successfully"
}