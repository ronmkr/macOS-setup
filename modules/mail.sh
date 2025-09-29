#!/usr/bin/env bash

setup_mail() {
    print_status "Configuring Mail.app settings..."
    log_info "Starting Mail configuration"

    # Performance optimizations
    print_status "Optimizing performance..."
    defaults_write "com.apple.mail" "DisableReplyAnimations" "true" "bool"
    defaults_write "com.apple.mail" "DisableSendAnimations" "true" "bool"
    defaults_write "com.apple.mail" "DisableURLLoading" "true" "bool"
    defaults_write "com.apple.mail" "EnableBundleImport" "false" "bool"
    defaults_write "com.apple.mail" "AutoFetch" "false" "bool"

    # Viewing and display
    print_status "Configuring viewing options..."
    defaults_write "com.apple.mail" "DisableInlineAttachmentViewing" "true" "bool"
    defaults_write "com.apple.mail" "LoadRemoteContent" "false" "bool"
    defaults_write "com.apple.mail" "PreferPlainText" "true" "bool"
    defaults_write "com.apple.mail" "ShowTo" "true" "bool"
    defaults_write "com.apple.mail" "MessageListFont" "LucidaGrande-Regular"
    defaults_write "com.apple.mail" "MessageFont" "LucidaGrande-Regular"
    defaults_write "com.apple.mail" "FixedWidthFont" "Monaco"

    # Compose settings
    print_status "Configuring compose settings..."
    defaults_write "com.apple.mail" "ComposeWindowLevel" "floating" "string"
    defaults_write "com.apple.mail" "NSUserKeyEquivalents" -dict-add "Send" "@\\U21a9"
    defaults_write "com.apple.mail" "AddressesIncludeNameOnPasteboard" "false" "bool"
    defaults_write "com.apple.mail" "ComposeTextSizeMultiplier" "1.2" "float"
    defaults_write "com.apple.mail" "QuotedTextColor" -string "0.0 0.0 0.5 1.0"

    # Threading and organization
    print_status "Configuring message organization..."
    defaults_write "com.apple.mail" "ConversationViewMarkAllAsRead" "false" "bool"
    defaults_write "com.apple.mail" "DraftsViewerAttributes" -dict-add "DisplayInThreadedMode" "yes"
    defaults_write "com.apple.mail" "DraftsViewerAttributes" -dict-add "SortedDescending" "yes"
    defaults_write "com.apple.mail" "DraftsViewerAttributes" -dict-add "SortOrder" "received-date"
    defaults_write "com.apple.mail" "ThreadingDefault" "true" "bool"
    defaults_write "com.apple.mail" "EnableThreadedMode" "true" "bool"

    # Privacy and security
    print_status "Configuring security settings..."
    defaults_write "com.apple.mail" "EnableSecureTransport" "true" "bool"
    defaults_write "com.apple.mail" "SuppressUserNotificationAfterDelay" "0.5" "float"
    defaults_write "com.apple.mail" "BlockLoadRemoteContent" "true" "bool"
    defaults_write "com.apple.mail" "DisableMailURLScheme" "true" "bool"

    # Notifications and alerts
    print_status "Configuring notifications..."
    defaults_write "com.apple.mail" "NewMessageSound" "Morse"
    defaults_write "com.apple.mail" "PlayMailSounds" "false" "bool"
    defaults_write "com.apple.mail" "MailUserNotificationScope" "inbox" "string"

    print_success "Mail settings applied"
    log_success "Mail configuration completed"
}

setup_mail_cleanup() {
    print_status "Cleaning up Mail settings..."
    log_info "Starting Mail cleanup"

    # Clear caches
    rm -rf ~/Library/Caches/com.apple.mail/* 2>/dev/null || true

    # Clear envelope index
    rm -rf ~/Library/Mail/V*/MailData/Envelope\ Index* 2>/dev/null || true

    # Clear attachment cache
    rm -rf ~/Library/Containers/com.apple.mail/Data/Library/Caches/com.apple.mail/Cache.db* 2>/dev/null || true

    # Remove temporary files
    find ~/Library/Mail -name ".DS_Store" -delete 2>/dev/null || true
    find ~/Library/Mail -name "*.mldata" -delete 2>/dev/null || true

    # Rebuild indexes
    /usr/bin/sqlite3 ~/Library/Mail/V*/MailData/Envelope\ Index "vacuum;" 2>/dev/null || true

    # Restart Mail
    print_status "Restarting Mail..."
    restart_app "Mail"

    print_success "Mail cleanup completed"
    log_success "Mail cleanup completed successfully"
}