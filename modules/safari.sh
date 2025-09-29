#!/usr/bin/env bash

setup_safari() {
    print_status "Configuring Safari settings..."
    log_info "Starting Safari configuration"

    # Privacy and security
    print_status "Configuring privacy settings..."
    defaults_write "com.apple.Safari" "HomePage" "about:blank"
    defaults_write "com.apple.Safari" "AutoOpenSafeDownloads" "false" "bool"
    defaults_write "com.apple.Safari" "UniversalSearchEnabled" "false" "bool"
    defaults_write "com.apple.Safari" "SuppressSearchSuggestions" "true" "bool"
    defaults_write "com.apple.Safari" "SendDoNotTrackHTTPHeader" "true" "bool"
    defaults_write "com.apple.Safari" "WebKitPreferences.privateClickMeasurementEnabled" "false" "bool"
    defaults_write "com.apple.Safari" "WebKitPreferences.dntHeaderEnabled" "true" "bool"
    defaults_write "com.apple.Safari" "com.apple.Safari.ContentPageGroupIdentifier.WebKit2StorageBlockingPolicy" "1"

    # Security settings
    print_status "Configuring security settings..."
    defaults_write "com.apple.Safari" "WarnAboutFraudulentWebsites" "true" "bool"
    defaults_write "com.apple.Safari" "WebKitPreferences.javaEnabled" "false" "bool"
    defaults_write "com.apple.Safari" "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled" "false" "bool"
    defaults_write "com.apple.Safari" "WebKitJavaScriptCanOpenWindowsAutomatically" "false" "bool"
    defaults_write "com.apple.Safari" "WebKitPreferences.plugInsEnabled" "false" "bool"
    defaults_write "com.apple.Safari" "com.apple.Safari.ContentPageGroupIdentifier.WebKit2PluginsEnabled" "false" "bool"

    # Search and autofill
    print_status "Configuring search and autofill..."
    defaults_write "com.apple.Safari" "WebKitPreferences.autofillPasswords" "false" "bool"
    defaults_write "com.apple.Safari" "AutoFillFromAddressBook" "false" "bool"
    defaults_write "com.apple.Safari" "AutoFillCreditCardData" "false" "bool"
    defaults_write "com.apple.Safari" "AutoFillMiscellaneousForms" "false" "bool"
    defaults_write "com.apple.Safari" "WebsiteSpecificSearchEnabled" "false" "bool"
    defaults_write "com.apple.Safari" "ShowFavoritesUnderSmartSearchField" "true" "bool"

    # Developer settings
    print_status "Configuring developer options..."
    defaults_write "com.apple.Safari" "IncludeInternalDebugMenu" "true" "bool"
    defaults_write "com.apple.Safari" "IncludeDevelopMenu" "true" "bool"
    defaults_write "com.apple.Safari" "WebKitDeveloperExtrasEnabledPreferenceKey" "true" "bool"
    defaults_write "com.apple.Safari" "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" "true" "bool"
    defaults_write "com.apple.Safari" "ShowDevelopMenu" "true" "bool"

    # Performance and behavior
    print_status "Optimizing performance settings..."
    defaults_write "com.apple.Safari" "DebugSnapshotsUpdatePolicy" "2"
    defaults_write "com.apple.Safari" "PreloadTopHit" "false" "bool"
    defaults_write "com.apple.Safari" "WebKitInitialTimedLayoutDelay" "0.25"
    defaults_write "com.apple.Safari" "WebKitPreferences.acceleratedDrawingEnabled" "true" "bool"
    defaults_write "com.apple.Safari" "WebKitPreferences.backspaceKeyNavigationEnabled" "true" "bool"

    # Tab and window behavior
    print_status "Configuring tab settings..."
    defaults_write "com.apple.Safari" "TabCreationPolicy" "2"  # Create tabs instead of windows
    defaults_write "com.apple.Safari" "OpenNewTabsInFront" "false" "bool"
    defaults_write "com.apple.Safari" "CommandClickMakesTabs" "true" "bool"
    defaults_write "com.apple.Safari" "OpenPrivateWindowWhenNotRestoringSessionAtLaunch" "true" "bool"
    defaults_write "com.apple.Safari" "ShowFullURLInSmartSearchField" "true" "bool"

    # Reader and content settings
    print_status "Configuring content settings..."
    defaults_write "com.apple.Safari" "WebKitPreferences.defaultTextEncodingName" "utf-8"
    defaults_write "com.apple.Safari" "WebKitPreferences.textAreasAreResizable" "true" "bool"
    defaults_write "com.apple.Safari" "ReadingListSaveArticlesOfflineAutomatically" "false" "bool"
    defaults_write "com.apple.Safari" "WebKitMediaPlaybackAllowsInline" "false" "bool"

    print_success "Safari settings applied"
}

setup_safari_cleanup() {
    print_status "Performing Safari cleanup..."

    # Clear Safari caches
    if [[ -d "${HOME}/Library/Caches/com.apple.Safari" ]]; then
        rm -rf "${HOME}/Library/Caches/com.apple.Safari"/* 2>/dev/null || true
    fi

    # Clear WebKit caches
    if [[ -d "${HOME}/Library/Caches/com.apple.WebKit.Networking" ]]; then
        rm -rf "${HOME}/Library/Caches/com.apple.WebKit.Networking"/* 2>/dev/null || true
    fi

    # Remove saved state
    if [[ -d "${HOME}/Library/Saved Application State/com.apple.Safari.savedState" ]]; then
        rm -rf "${HOME}/Library/Saved Application State/com.apple.Safari.savedState"/* 2>/dev/null || true
    fi

    # Restart Safari to apply changes
    restart_app "Safari"

    print_success "Safari cleanup completed"
}