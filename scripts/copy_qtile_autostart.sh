#!/bin/bash
    copy_qtile_autostart() {
          echo "Copying Qtile configuration file..."
          local source="/home/mario/mArch/config/qtile_autostart.sh"
          local target="/home/mario/.config/qtile/qtileAutoStart.sh"
          mkdir -p "$(dirname "$target")"

          # Copy the configuration file from 'configs/qtile.py' to the target directory
          cp "$source" "$target"
          chmod +x $target
          echo "Qtile configuration file copied to ~/.config/qtile/config.py."
      }
