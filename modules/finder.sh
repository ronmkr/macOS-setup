#!/usr/bin/env bash

setup_finder() {
    print_status "Configuring Finder settings..."
    log_info "Starting Finder configuration"

    # Desktop view settings
    print_status "Configuring desktop view..."
    defaults_write "com.apple.finder" "ShowExternalHardDrivesOnDesktop" "true" "bool"
    defaults_write "com.apple.finder" "ShowHardDrivesOnDesktop" "true" "bool"
    defaults_write "com.apple.finder" "ShowMountedServersOnDesktop" "true" "bool"
    defaults_write "com.apple.finder" "ShowRemovableMediaOnDesktop" "true" "bool"
    defaults_write "com.apple.finder" "CreateDesktop" "true" "bool"  # Show desktop icons

    # Window view settings
    print_status "Configuring window appearance..."
    defaults_write "com.apple.finder" "ShowStatusBar" "true" "bool"
    defaults_write "com.apple.finder" "ShowPathbar" "true" "bool"
    defaults_write "com.apple.finder" "ShowTabView" "true" "bool"
    defaults_write "com.apple.finder" "ShowPreviewPane" "true" "bool"
    defaults_write "com.apple.finder" "_FXShowPosixPathInTitle" "true" "bool"
    defaults_write "com.apple.finder" "WantsTitleFromURI" "true" "bool"

    # File visibility settings
    print_status "Configuring file visibility..."
    defaults_write "com.apple.finder" "AppleShowAllFiles" "true" "bool"
    defaults_write "NSGlobalDomain" "AppleShowAllExtensions" "true" "bool"
    defaults_write "com.apple.finder" "FXEnableExtensionChangeWarning" "false" "bool"

    # Default view style (Icon = icnv, List = Nlsv, Column = clmv, Gallery = glyv)
    defaults_write "com.apple.finder" "FXPreferredViewStyle" "clmv"

    # Search settings
    print_status "Configuring search preferences..."
    defaults_write "com.apple.finder" "FXDefaultSearchScope" "SCcf"  # Search current folder
    defaults_write "com.apple.finder" "FXDefaultSearchViewStyle" "Nlsv"  # List view for search results
    defaults_write "com.apple.finder" "FinderSpawnTab" "true" "bool"  # Search in new tab

    # Performance and behavior
    print_status "Optimizing performance settings..."
    defaults_write "com.apple.finder" "FXRecentFolders" -array  # Clear recent folders
    defaults_write "com.apple.finder" "FXRemoveOldTrashItems" "true" "bool"
    defaults_write "com.apple.desktopservices" "DSDontWriteNetworkStores" "true" "bool"
    defaults_write "com.apple.desktopservices" "DSDontWriteUSBStores" "true" "bool"
    defaults_write "com.apple.finder" "FXEnableSlowAnimation" "false" "bool"

    # Spring loading settings
    print_status "Configuring spring loading..."
    defaults_write "NSGlobalDomain" "com.apple.springing.enabled" "true" "bool"
    defaults_write "NSGlobalDomain" "com.apple.springing.delay" "0.5" "float"

    # Quick Look settings
    print_status "Configuring Quick Look..."
    defaults_write "com.apple.finder" "QLEnableTextSelection" "true" "bool"
    defaults_write "com.apple.finder" "QLEnableXRayFolders" "true" "bool"

    # Show hidden folders
    print_status "Showing system folders..."
    chflags nohidden ~/Library
    sudo chflags nohidden /Volumes
    xattr -d com.apple.FinderInfo ~/Library 2>/dev/null || true

    # Sidebar settings
    print_status "Configuring sidebar..."
    defaults write "com.apple.finder" "ShowRecentTags" "false" "bool"
    defaults write "com.apple.finder" "SidebarDevicesSectionDisclosedState" "true" "bool"
    defaults write "com.apple.finder" "SidebarPlacesSectionDisclosedState" "true" "bool"
    defaults write "com.apple.finder" "SidebarShowingSignedIntoiCloud" "false" "bool"

    print_success "Finder settings applied"
    log_success "Finder configuration completed"
}

setup_finder_cleanup() {
    print_status "Cleaning up Finder settings..."
    log_info "Starting Finder cleanup"

    # Remove .DS_Store files
    print_status "Removing .DS_Store files..."
    find ~ -name ".DS_Store" -type f -delete 2>/dev/null || true

    # Clear various caches
    print_status "Clearing Finder caches..."
    rm -rf ~/Library/Caches/com.apple.finder/* 2>/dev/null || true
    rm -rf ~/Library/Preferences/com.apple.finder.plist.lockfile 2>/dev/null || true

    # Clear Quick Look cache
    if is_sudo; then
        sudo rm -rf /private/var/folders/*/*/*/com.apple.QuickLook.thumbnailcache 2>/dev/null || true
    fi

    # Clear recent items
    print_status "Clearing recent items..."
    osascript -e 'tell application "System Events" to tell appearance preferences to set recent applications limit to 0'
    osascript -e 'tell application "System Events" to tell appearance preferences to set recent documents limit to 0'
    osascript -e 'tell application "System Events" to tell appearance preferences to set recent servers limit to 0'

    # Restart Finder to apply changes
    print_status "Restarting Finder..."
    restart_app "Finder"

    print_success "Finder cleanup completed"
    log_success "Finder cleanup completed successfully"
}