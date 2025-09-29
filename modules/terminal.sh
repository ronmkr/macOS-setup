#!/usr/bin/env bash

setup_terminal() {
    print_status "Configuring Terminal.app settings..."
    log_info "Starting Terminal configuration"

    # Encoding settings
    print_status "Configuring encoding settings..."
    defaults_write "com.apple.terminal" "StringEncodings" -array 4  # UTF-8
    defaults_write "com.apple.terminal" "DefaultEncoding" -int 4  # UTF-8

    # Security settings
    print_status "Configuring security settings..."
    defaults_write "com.apple.terminal" "SecureKeyboardEntry" "true" "bool"
    defaults_write "com.apple.terminal" "Shell" -string "/bin/bash"
    defaults_write "com.apple.terminal" "shellLaunchAction" -int 1  # New window with default profile

    # Window settings
    print_status "Configuring window appearance..."
    defaults_write "com.apple.terminal" "Default Window Settings" "Pro"
    defaults_write "com.apple.terminal" "Startup Window Settings" "Pro"
    defaults_write "com.apple.terminal" "WindowRestorationEnabled" "true" "bool"
    defaults_write "com.apple.terminal" "ResolvesFolderBookmarks" "true" "bool"

    # Pro theme customization
    print_status "Configuring theme settings..."
    defaults_write "com.apple.terminal" "Pro" -dict-add \
        "Bell" -bool false \
        "CursorBlink" -bool true \
        "CursorType" -int 2 \
        "UseBrightBold" -bool true \
        "VisualBell" -bool false \
        "CloseOnEndOfFile" -bool false \
        "ShowActiveProcessArgumentsInTitle" -bool true \
        "ShowActiveProcessInTitle" -bool true \
        "ShowCommandKeyInTitle" -bool true \
        "ShowDimensionsInTitle" -bool false \
        "ShowRepresentedURLInTitle" -bool true \
        "ShowRepresentedURLPathInTitle" -bool true \
        "ShowShellCommandInTitle" -bool true \
        "ShowTTYNameInTitle" -bool false \
        "ShowWindowSettingsNameInTitle" -bool false \
        "TerminalType" -string "xterm-256color" \
        "TextBoldColor" -data "62706C6973743030D4010203040506070A582476657273696F6E592461726368697665725424746F7058246F626A6563747312000186A0A2080953246E756C6CD3090A0B0C0D0E5F101072474233436F6D706F6E656E74735F101172474241436F6D706F6E656E74735F101172474242436F6D706F6E656E747380038003800380030101010158247665727"

    # Text settings
    print_status "Configuring text settings..."
    defaults_write "com.apple.terminal" "FontAntialias" "true" "bool"
    defaults_write "com.apple.terminal" "FontHeightSpacing" "1.1" "float"
    defaults_write "com.apple.terminal" "FontWidthSpacing" "1.0" "float"
    defaults_write "com.apple.terminal" "ShouldRestoreContent" "true" "bool"

    # Keyboard and selection
    print_status "Configuring keyboard settings..."
    defaults_write "com.apple.terminal" "AutoMarkPromptLines" "true" "bool"
    defaults_write "com.apple.terminal" "DoubleClickSelectsWord" "true" "bool"
    defaults_write "com.apple.terminal" "TripleClickSelectsLine" "true" "bool"
    defaults_write "com.apple.terminal" "Option Click Moves Cursor" "true" "bool"

    # Scrollback and history
    print_status "Configuring history settings..."
    defaults_write "com.apple.terminal" "ScrollbackLines" "10000" "int"
    defaults_write "com.apple.terminal" "SaveLines" "10000" "int"
    defaults_write "com.apple.terminal" "ShouldLimitScrollback" "false" "bool"
    defaults_write "com.apple.terminal" "ScrollAlternateScreen" "true" "bool"

    # Terminal focus
    print_status "Configuring focus settings..."
    defaults_write "com.apple.terminal" "FocusFollowsMouse" "false" "bool"
    defaults_write "com.apple.terminal" "TabsWhenOpening" "true" "bool"
    defaults_write "com.apple.terminal" "SecureTextEntry" "true" "bool"

    print_success "Terminal settings applied"
    log_info "Terminal configuration completed"
}

setup_terminal_cleanup() {
    print_status "Performing Terminal cleanup..."
    log_info "Starting Terminal cleanup"

    # Clear terminal logs
    if [[ -d "${HOME}/Library/Logs/Terminal" ]]; then
        rm -rf "${HOME}/Library/Logs/Terminal"/* 2>/dev/null || true
    fi

    # Clear terminal state
    if [[ -d "${HOME}/Library/Saved Application State/com.apple.Terminal.savedState" ]]; then
        rm -rf "${HOME}/Library/Saved Application State/com.apple.Terminal.savedState"/* 2>/dev/null || true
    fi

    # Clear terminal preferences cache
    if [[ -d "${HOME}/Library/Caches/com.apple.Terminal" ]]; then
        rm -rf "${HOME}/Library/Caches/com.apple.Terminal"/* 2>/dev/null || true
    fi

    # Restart Terminal
    restart_app "Terminal"

    print_success "Terminal cleanup completed"
    log_info "Terminal cleanup finished"
}