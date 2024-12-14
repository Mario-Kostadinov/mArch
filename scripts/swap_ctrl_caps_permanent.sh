swap_ctrl_caps_permanent() {
    echo "Copying ctrl:swapcaps configuration..."

    # Define source and target paths
    src="/home/mario/mArch/config/00-keyboard.conf"
    dest="/etc/X11/xorg.conf.d/00-keyboard.conf"

    # Create target directory if it doesn't exist
    mkdir -p "$(dirname "$dest")"

    # Copy the configuration file
    if cp "$src" "$dest"; then
        echo "ctrl:swapcaps configuration copied to $dest successfully."
    else
        echo "Error: Failed to copy ctrl:swapcaps configration from $src to $dest."
    fi
  }
