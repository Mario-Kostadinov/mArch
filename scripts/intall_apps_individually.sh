install_apps_individually() {
    # Retrieve the comma-separated list of applications passed as an argument
    local app_list=$1

    # Convert the comma-separated list into a space-separated list
    local apps=$(echo "$app_list" | tr ',' ' ')

    # Loop through each application
    for app in $apps; do
        # Check if the application is already installed
        if pacman -Q "$app" &>/dev/null; then
            echo "Skipping '$app': already installed."
        else
            echo "Installing '$app'..."
            sudo pacman -S --noconfirm "$app"
            echo "'$app' has been installed."
        fi
    done

    echo "All applications processed."
}
