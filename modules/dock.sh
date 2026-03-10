#!/usr/bin/env bash

setup_dock() {
    print_status "Configuring Dock appearance settings..."
    log_info "Starting Dock configuration"

    # Basic appearance
    defaults_write "com.apple.dock" "tilesize" "36"
    defaults_write "com.apple.dock" "magnification" "true" "bool"
    defaults_write "com.apple.dock" "mineffect" "scale"
    defaults_write "com.apple.dock" "minimize-to-application" "true" "bool"

    # Position and behavior
    defaults_write "com.apple.dock" "orientation" "bottom"
    defaults_write "com.apple.dock" "autohide" "true" "bool"
    defaults_write "com.apple.dock" "show-recent-apps" "false" "bool"

    # Animation and performance
    defaults_write "com.apple.dock" "launchanim" "false" "bool"
    defaults_write "com.apple.dock" "autohide-delay" "0" "float"

    # Dock Items Management (requires dockutil)
    if command_exists dockutil; then
        print_status "Managing Dock items with dockutil..."
        
        if [[ "$DRY_RUN" == "true" ]]; then
            print_status "[DRY-RUN] Would remove all items and add default apps"
        else
            # Remove everything first
            sudo -u "${USER_NAME}" dockutil --remove all --no-restart
            
            # Add essential apps
            local apps=(
                "/System/Applications/Launchpad.app"
                "/Applications/Google Chrome.app"
                "/Applications/Visual Studio Code.app"
                "/System/Applications/Utilities/Terminal.app"
                "/Applications/iTerm.app"
                "/System/Applications/System Settings.app"
            )

            for app in "${apps[@]}"; do
                if [[ -d "$app" ]]; then
                    sudo -u "${USER_NAME}" dockutil --add "$app" --no-restart
                fi
            done
            
            # Add common folders
            sudo -u "${USER_NAME}" dockutil --add "${USER_HOME}/Downloads" --view grid --display folder --no-restart
        fi
    else
        print_warning "dockutil not found. Skipping Dock item management."
    fi

    print_success "Dock settings applied"
}

setup_dock_cleanup() {
    print_status "Cleaning up Dock configuration..."
    restart_app "Dock"
}
