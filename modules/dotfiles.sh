#!/usr/bin/env bash

setup_dotfiles() {
    print_status "Configuring dotfiles symlinks..."
    
    local dotfiles_dir="${SCRIPT_DIR}/dotfiles"
    if [[ ! -d "$dotfiles_dir" ]]; then
        print_warning "No 'dotfiles' directory found in project root. Skipping."
        return 0
    fi

    # List of files to symlink (relative to dotfiles_dir)
    # This could also be externalized to a config file
    local files=(
        ".zshrc"
        ".gitconfig"
        ".vimrc"
        ".p10k.zsh"
    )

    for file in "${files[@]}"; do
        local source_file="${dotfiles_dir}/${file}"
        local target_file="${USER_HOME}/${file}"

        if [[ -f "$source_file" ]]; then
            print_status "Linking $file to $target_file..."
            
            if [[ "$DRY_RUN" == "true" ]]; then
                print_status "[DRY-RUN] Would symlink $source_file -> $target_file"
            else
                # Backup existing file if it's not a symlink
                if [[ -f "$target_file" && ! -L "$target_file" ]]; then
                    mv "$target_file" "${target_file}.bak"
                fi
                
                # Create symlink as the user
                sudo -u "${USER_NAME}" ln -sf "$source_file" "$target_file"
            fi
        else
            print_warning "Source file $source_file not found. Skipping."
        fi
    done

    print_success "Dotfiles configuration completed"
}

setup_dotfiles_cleanup() {
    :
}
