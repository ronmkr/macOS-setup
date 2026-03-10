#!/usr/bin/env bash

setup_brew() {
    print_status "Configuring Homebrew and packages..."

    # Check for Homebrew
    if ! command_exists brew; then
        print_status "Installing Homebrew..."
        if [[ "$DRY_RUN" == "true" ]]; then
            print_status "[DRY-RUN] Would install Homebrew"
        else
            sudo -u "${USER_NAME}" bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            local shell_rc="${USER_HOME}/.zprofile"
            if [[ -f "/opt/homebrew/bin/brew" ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
                grep -q "homebrew" "$shell_rc" 2>/dev/null || echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$shell_rc"
            elif [[ -f "/usr/local/bin/brew" ]]; then
                eval "$(/usr/local/bin/brew shellenv)"
                grep -q "homebrew" "$shell_rc" 2>/dev/null || echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$shell_rc"
            fi
            chown "${USER_NAME}" "$shell_rc"
        fi
    fi

    # Update Homebrew
    print_status "Updating Homebrew..."
    if [[ "$DRY_RUN" == "true" ]]; then
        print_status "[DRY-RUN] Would run 'brew update'"
    else
        sudo -u "${USER_NAME}" brew update
    fi

    # Check for Brewfile
    local brewfile="${SCRIPT_DIR}/config/Brewfile"
    if [[ -f "$brewfile" ]]; then
        print_status "Installing apps from Brewfile: $brewfile"
        if [[ "$DRY_RUN" == "true" ]]; then
            print_status "[DRY-RUN] Would run 'brew bundle' using $brewfile"
        else
            sudo -u "${USER_NAME}" brew bundle --file="$brewfile"
        fi
    else
        # Fallback to defaults if Brewfile doesn't exist
        print_warning "Brewfile not found, using default lists."
        local brews=("git" "vim" "wget" "jq" "mas" "dockutil")
        local casks=("visual-studio-code" "iterm2" "google-chrome")

        for item in "${brews[@]}"; do
            [[ "$DRY_RUN" == "true" ]] && print_status "[DRY-RUN] Would install brew: $item" || sudo -u "${USER_NAME}" brew install "$item" || true
        done
        for item in "${casks[@]}"; do
            [[ "$DRY_RUN" == "true" ]] && print_status "[DRY-RUN] Would install cask: $item" || sudo -u "${USER_NAME}" brew install --cask "$item" || true
        done
    fi

    # Cleanup
    if [[ "$DRY_RUN" == "true" ]]; then
        print_status "[DRY-RUN] Would run 'brew cleanup'"
    else
        sudo -u "${USER_NAME}" brew cleanup
    fi

    print_success "Homebrew configuration completed"
}

setup_brew_cleanup() {
    :
}
