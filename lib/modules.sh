#!/usr/bin/env bash

# Module dependencies and requirements
declare -A MODULE_DEPS=(
    ["finder"]=""
    ["dock"]=""
    ["safari"]=""
    ["mail"]=""
    ["terminal"]=""
    ["system"]="security input"
    ["input"]=""
    ["security"]=""
    ["cleanup"]="all"
    ["backup"]=""
)

# Module order (for sequential processing)
declare -a MODULE_ORDER=(
    "security"
    "system"
    "input"
    "finder"
    "dock"
    "terminal"
    "safari"
    "mail"
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

    for module in "${MODULE_ORDER[@]}"; do
        if [[ " ${ENABLED_FEATURES[*]} " =~ " $module " ]]; then
            sorted+=("$module")
        fi
    done

    ENABLED_FEATURES=("${sorted[@]}")
}