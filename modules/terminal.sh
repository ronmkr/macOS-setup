#!/usr/bin/env bash

setup_terminal() {
    print_status "Configuring Terminal.app settings..."
    log_info "Starting Terminal configuration"

    # Encoding settings
    defaults_write "com.apple.terminal" "StringEncodings" -array 4  # UTF-8
    defaults_write "com.apple.terminal" "DefaultEncoding" -int 4  # UTF-8

    # Security settings
    defaults_write "com.apple.terminal" "SecureKeyboardEntry" "true" "bool"
    
    # Modern macOS uses Zsh as the default shell
    local default_shell="/bin/zsh"
    [[ -f "/usr/local/bin/zsh" ]] && default_shell="/usr/local/bin/zsh"
    
    defaults_write "com.apple.terminal" "Shell" "$default_shell"
    defaults_write "com.apple.terminal" "shellLaunchAction" "1" "int"

    # Theme and Window settings
    defaults_write "com.apple.terminal" "Default Window Settings" "Pro"
    defaults_write "com.apple.terminal" "Startup Window Settings" "Pro"
    defaults_write "com.apple.terminal" "WindowRestorationEnabled" "true" "bool"

    # History settings
    defaults_write "com.apple.terminal" "ScrollbackLines" "10000" "int"
    defaults_write "com.apple.terminal" "ShouldLimitScrollback" "false" "bool"

    # Tabs
    defaults_write "com.apple.terminal" "TabsWhenOpening" "true" "bool"

    print_success "Terminal settings applied"
}

setup_terminal_cleanup() {
    print_status "Performing Terminal cleanup..."
    # Restart Terminal
    restart_app "Terminal"
}
