#!/usr/bin/env bash

setup_developer() {
    print_status "Configuring Developer environment..."

    # Check for Xcode Command Line Tools
    if ! xcode-select -p &>/dev/null; then
        print_status "Installing Xcode Command Line Tools..."
        if [[ "$DRY_RUN" == "true" ]]; then
            print_status "[DRY-RUN] Would install Xcode CLI Tools"
        else
            # This will trigger a GUI prompt if not installed
            xcode-select --install
            
            print_warning "A GUI prompt has appeared. Please complete the installation and then re-run this script."
            exit 0
        fi
    else
        print_status "Xcode Command Line Tools already installed."
    fi

    # Set up global git config
    print_status "Setting up global git config..."
    if [[ "$DRY_RUN" == "true" ]]; then
        print_status "[DRY-RUN] Would set git config"
    else
        sudo -u "${USER_NAME}" git config --global core.editor "vim"
        sudo -u "${USER_NAME}" git config --global pull.rebase true
        sudo -u "${USER_NAME}" git config --global init.defaultBranch main
    fi

    print_success "Developer environment setup completed"
}

setup_developer_cleanup() {
    :
}
