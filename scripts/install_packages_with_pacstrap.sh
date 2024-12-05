#!/bin/bash
install_packages_with_pacstrap() {
    local package_list=$1
    local target_dir="/mnt"

    # Transform comma-separated list to space-separated list
    local packages=$(echo "$package_list" | tr ',' ' ')

    # Add the CPU microcode package
    local cpu_microcode=$2
    if [[ $? -ne 0 ]]; then
        exit 1
    fi

    # Append the CPU microcode package
    packages="$packages $cpu_microcode"

    echo "Installing packages: $packages"

    pacstrap -K "$target_dir" $packages

    if [[ $? -eq 0 ]]; then
        echo "Packages successfully installed on $target_dir"
    else
        echo "Failed to install packages" >&2
        exit 1
    fi
}
