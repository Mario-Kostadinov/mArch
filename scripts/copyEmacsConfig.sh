#!/bin/bash
copyEmacsConfig() {
    echo "Copying Emacs configuration..."

    # Define source and target paths
    src="/home/mario/mArch/config/emacs.el"
    dest="/home/mario/.emacs.d/init.el"

    # Create target directory if it doesn't exist
    mkdir -p "$(dirname "$dest")"

    # Copy the configuration file
    if cp "$src" "$dest"; then
        echo "Emacs configuration copied to $dest successfully."
    else
        echo "Error: Failed to copy Emacs configuration from $src to $dest."
    fi
}
