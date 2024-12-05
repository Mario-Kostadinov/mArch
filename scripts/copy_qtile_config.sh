#!/bin/bash
  copy_qtile_config() {
        echo "Copying Qtile configuration file..."
        local source="/home/mario/mos/dist/configs/qtile.py"
        local target="/home/mario/.config/qtile/config.py"
        mkdir -p "$(dirname "$target")"

        # Copy the configuration file from 'configs/qtile.py' to the target directory
        cp "$source" "$target"

        echo "Qtile configuration file copied to ~/.config/qtile/config.py."
    }
