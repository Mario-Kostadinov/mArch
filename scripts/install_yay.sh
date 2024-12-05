#!/bin/bash
install_yay() {
    # Ensure base-devel is installed
    #echo "Installing base-devel group (if not already installed)..."
    #sudo pacman -S --needed base-devel

    # Create a directory for the build if it doesn't exist
    if [ ! -d "$HOME/Downloads" ]; then
        mkdir -p "$HOME/Downloads"
    fi

    # Change to the Downloads directory
    cd "$HOME/Downloads" || { echo "Failed to enter Downloads directory"; return 1; }

    # Clone the yay repository if it doesn't exist
    if [ ! -d "yay-bin" ]; then
        echo "Cloning yay AUR repository..."
        git clone https://aur.archlinux.org/yay-bin.git
    else
        echo "yay-bin directory already exists. Skipping clone."
    fi

    # Change to the yay directory and build the package
    cd yay-bin || { echo "Failed to enter yay-bin directory"; return 1; }

    echo "Building and installing yay..."
    makepkg -si

    echo "yay installation complete."
}
