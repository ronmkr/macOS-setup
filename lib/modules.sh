#!/usr/bin/env bash

# Module dependencies and requirements
declare -A MODULE_DEPS=(
    ["finder"]=""
    ["dock"]=""
    ["safari"]=""
    ["mail"]=""
    ["terminal"]=""
    ["system"]="security input developer"
    ["input"]=""
    ["security"]=""
    ["cleanup"]="all"
    ["backup"]=""
    ["brew"]="developer"
    ["developer"]=""
    ["softwareupdate"]=""
)

# Module order (for sequential processing)
declare -a MODULE_ORDER=(
    "softwareupdate"
    "developer"
    "brew"
    "security"
    "system"
    "input"
    "finder"
    "dock"
    "terminal"
    "mail"
    "safari"
    "cleanup"
)

# Module requirements check functions
check_module_deps() {
    local module="$1"
    local deps="${MODULE_DEPS[$module]}"

    if [[ -n "$deps" ]]; then
        for dep in $deps; do
            if [[ "$dep" == "all" ]]; then
                continue
            fi
            if [[ ! " ${ENABLED_FEATURES[*]} " =~ " $dep " ]]; then
                print_warning "Module '$module' requires '$dep'. Enabling it."
                ENABLED_FEATURES+=("$dep")
            fi
        done
    fi
}

# Sort modules based on dependencies
sort_modules() {
    local -a sorted=()
    local module

    # First, ensure all dependencies are met
    for module in "${ENABLED_FEATURES[@]}"; do
        check_module_deps "$module"
    done

    # Then sort according to MODULE_ORDER
    for module in "${MODULE_ORDER[@]}"; do
        if [[ " ${ENABLED_FEATURES[*]} " =~ " $module " ]]; then
            sorted+=("$module")
        fi
    done

    ENABLED_FEATURES=("${sorted[@]}")
}
