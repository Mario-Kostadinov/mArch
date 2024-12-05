#!/bin/bash
install_apps() {
    # Retrieve the comma-separated list of applications passed as an argument
    local app_list=$1

    # Convert the comma-separated list into a space-separated list
    local apps=$(echo "$app_list" | tr ',' ' ')

    echo "Installing the following apps: $apps"

    # Install all apps in one command
    sudo pacman -S --noconfirm $apps

    echo "All apps have been installed."
}
