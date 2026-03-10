#!/usr/bin/env bash

# Use global USER_HOME and USER_NAME from lib/utils.sh

get_app_cache_paths() {
    local bundle_id="$1"
    local cache_paths=(
        "${USER_HOME}/Library/Caches/${bundle_id}"
        "${USER_HOME}/Library/Containers/${bundle_id}/Data/Library/Caches"
        "${USER_HOME}/Library/Application Support/${bundle_id}/Caches"
    )
    printf "%s\n" "${cache_paths[@]}"
}

safe_rm() {
    local path="$1"
    if [[ -e "$path" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            print_status "[DRY-RUN] Would remove: $path"
        else
            rm -rf "$path" 2>/dev/null || true
        fi
    fi
}

cleanup_detected_tools() {
    print_status "Cleaning development tool caches..."
    
    # Define tool cache paths relative to USER_HOME
    declare -A caches=(
        ["vscode"]="${USER_HOME}/Library/Application Support/Code/Cache"
        ["vscodedata"]="${USER_HOME}/Library/Application Support/Code/CachedData"
        ["gradle"]="${USER_HOME}/.gradle/caches"
        ["npm"]="${USER_HOME}/.npm"
        ["pip"]="${USER_HOME}/Library/Caches/pip"
        ["yarn"]="${USER_HOME}/Library/Caches/Yarn"
    )

    for tool in "${!caches[@]}"; do
        if [[ -d "${caches[$tool]}" ]]; then
            print_status "Cleaning $tool cache..."
            safe_rm "${caches[$tool]}/*"
        fi
    done

    # Run tool-specific cleanup commands as the user
    local tools=("brew" "npm" "yarn" "pip3" "gem" "pod")
    for tool in "${tools[@]}"; do
        if command_exists "$tool"; then
            print_status "Running $tool cleanup..."
            if [[ "$DRY_RUN" == "true" ]]; then
                print_status "[DRY-RUN] Would run $tool cleanup"
            else
                case "$tool" in
                    brew) sudo -u "${USER_NAME}" brew cleanup --prune=all &>/dev/null || true ;;
                    npm)  sudo -u "${USER_NAME}" npm cache clean --force &>/dev/null || true ;;
                    yarn) sudo -u "${USER_NAME}" yarn cache clean &>/dev/null || true ;;
                    *)    # Generic cleanup or skip if unknown
                        ;;
                esac
            fi
        fi
    done
}

setup_cleanup() {
    print_status "Starting system cleanup..."
    log_info "Beginning system cleanup"

    # 1. User Caches
    print_status "Cleaning user caches..."
    safe_rm "${USER_HOME}/Library/Caches/*"
    safe_rm "${USER_HOME}/Library/Logs/*"
    
    # 2. Browser Caches
    print_status "Cleaning browser caches..."
    safe_rm "${USER_HOME}/Library/Application Support/Google/Chrome/Default/Cache/*"
    safe_rm "${USER_HOME}/Library/Containers/com.apple.Safari/Data/Library/Caches/*"

    # 3. Development Tools
    cleanup_detected_tools

    # 4. System Cleanup (Root)
    print_status "Cleaning system-level temporary files..."
    safe_rm "/private/var/folders/*/*/*/*"
    safe_rm "/private/tmp/*"
    
    if [[ "$DRY_RUN" != "true" ]]; then
        # Rebuild Spotlight index
        sudo mdutil -E / &>/dev/null || true
        # Flush DNS
        sudo dscacheutil -flushcache
        sudo killall -HUP mDNSResponder
    fi

    # 5. Empty Trash
    print_status "Emptying trash..."
    safe_rm "${USER_HOME}/.Trash/*"

    print_success "Cleanup completed"
}

setup_cleanup_cleanup() {
    :
}
