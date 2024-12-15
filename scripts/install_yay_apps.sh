install_yay_apps() {
    # Retrieve the comma-separated list of applications passed as an argument
    local app_list=$1

    # Convert the comma-separated list into a space-separated list
    local apps=$(echo "$app_list" | tr ',' ' ')

    # Loop through each application
    for app in $apps; do
        # Check if the application is already installed
        if yay -Q "$app" &>/dev/null; then
            echo "Skipping '$app': already installed."
        else
            echo "Installing '$app'..."
            yay -S --noconfirm "$app"
            echo "'$app' has been installed."
        fi
    done

    echo "All applications processed."
}
