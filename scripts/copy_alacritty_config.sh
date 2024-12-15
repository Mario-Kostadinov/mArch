#!/bin/bash
copy_alacritty_config() {
    echo "Copying Alacritty configuration..."

    # Define source and target paths
    src="/home/mario/mArch/config/alacritty.toml"
    dest="/home/mario/.config/alacritty/alacritty.toml"

    # Create target directory if it doesn't exist
    mkdir -p "$(dirname "$dest")"

    # Copy the configuration file
    if cp "$src" "$dest"; then
        echo "Alacritty configuration copied to $dest successfully."
    else
        echo "Error: Failed to copy Alacritty configration from $src to $dest."
    fi
}
