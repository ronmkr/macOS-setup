#!/usr/bin/env bash

setup_dock() {
  print_status "Configuring Dock settings..."
  log_info "Starting Dock configuration"

  # Basic appearance
  defaults_write "com.apple.dock" "tilesize" "36"                              # Icon size
  defaults_write "com.apple.dock" "largesize" "64" "float"                     # Icon size when magnified
  defaults_write "com.apple.dock" "magnification" "true" "bool"                # Enable magnification
  defaults_write "com.apple.dock" "mineffect" "scale"                          # Minimize effect: genie, scale, or suck
  defaults_write "com.apple.dock" "minimize-to-application" "true" "bool"      # Minimize to app icon

  # Position and behavior
  defaults_write "com.apple.dock" "orientation" "bottom"                       # Dock position: bottom, left, or right
  defaults_write "com.apple.dock" "autohide" "true" "bool"                     # Auto-hide the Dock
  defaults_write "com.apple.dock" "showhidden" "true" "bool"                   # Show indicators for hidden apps
  defaults_write "com.apple.dock" "show-process-indicators" "true" "bool"      # Show app indicators
  defaults_write "com.apple.dock" "show-recent-apps" "false" "bool"            # Don't show recent apps

  # Animation and performance
  defaults_write "com.apple.dock" "launchanim" "false" "bool"                  # Disable app launch animation
  defaults_write "com.apple.dock" "expose-animation-duration" "0.15" "float"   # Mission Control animation speed
  defaults_write "com.apple.dock" "autohide-delay" "0" "float"                 # Remove auto-hide delay
  defaults_write "com.apple.dock" "autohide-time-modifier" "0.5" "float"       # Speed up auto-hide animation
  defaults_write "com.apple.dock" "workspaces-edge-delay" "0.2" "float"        # Space switching delay

  # Mission Control and Spaces
  defaults_write "com.apple.dock" "expose-group-by-app" "false" "bool"         # Don't group windows by app
  defaults_write "com.apple.dock" "mru-spaces" "false" "bool"                  # Don't rearrange spaces
  defaults_write "com.apple.dock" "dashboard-in-overlay" "true" "bool"         # Dashboard as overlay
  defaults_write "com.apple.dock" "enable-spring-load-actions-on-all-items" "true" "bool"

  # Hot corners
  # Possible values:
  #  0: no-op
  #  2: Mission Control
  #  3: Show application windows
  #  4: Desktop
  #  5: Start screen saver
  #  6: Disable screen saver
  #  7: Dashboard
  # 10: Put display to sleep
  # 11: Launchpad
  # 12: Notification Center
  # Top left corner → Mission Control
  defaults_write "com.apple.dock" "wvous-tl-corner" "2"
  defaults_write "com.apple.dock" "wvous-tl-modifier" "0"

  # Top right corner → Desktop
  defaults_write "com.apple.dock" "wvous-tr-corner" "4"
  defaults_write "com.apple.dock" "wvous-tr-modifier" "0"

  # Bottom left corner → Start screen saver
  defaults_write "com.apple.dock" "wvous-bl-corner" "5"
  defaults_write "com.apple.dock" "wvous-bl-modifier" "0"

  # Bottom right corner → Quick Note
  defaults_write "com.apple.dock" "wvous-br-corner" "14"
  defaults_write "com.apple.dock" "wvous-br-modifier" "0"

  print_success "Dock settings applied"
  log_success "Dock configuration completed"
}

setup_dock_cleanup() {
  print_status "Cleaning up Dock configuration..."

  # Clear the Dock's orientation cache
  defaults delete "com.apple.dock" "last-orientation" 2>/dev/null || true

  # Remove cached thumbnails
  rm -rf ~/Library/Application\ Support/Dock/*.db 2>/dev/null || true

  # Restart Dock to apply changes
  restart_app "Dock"
  log_info "Dock restarted to apply changes"
}