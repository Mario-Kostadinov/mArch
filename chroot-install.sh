set_time_zone() {
    read -p "Do you want to set the time zone? (y/n, default: y): " time_zone_choice
    time_zone_choice=${time_zone_choice:-y}  # Default to 'y' if no input is provided

    if [[ "$time_zone_choice" =~ ^[Yy]$ ]]; then
        echo "Setting the time zone..."

        # Ask for the region and city (example: America/New_York)
        read -p "Enter your time zone (e.g., America/New_York): " time_zone
        ln -sf "/usr/share/zoneinfo/$time_zone" /etc/localtime

        echo "Generating hardware clock settings..."
        hwclock --systohc

        # Setting up time synchronization (systemd-timesyncd)
        echo "Enabling NTP for time synchronization..."
        systemctl enable systemd-timesyncd
        systemctl start systemd-timesyncd

        echo "Time zone and synchronization set successfully."
    else
        echo "Skipping time zone setup."
    fi
}

set_time_zone
wait 1

configure_localization() {
      read -p "Do you want to configure localization? (y/n, default: y): " localization_choice
      localization_choice=${localization_choice:-y}  # Default to 'y' if no input is provided

      if [[ "$localization_choice" =~ ^[Yy]$ ]]; then
          echo "Configuring localization..."

          # Uncomment the required locales in /etc/locale.gen
          echo "Uncommenting en_US.UTF-8 UTF-8 and bg_BG.UTF-8 UTF-8 in /etc/locale.gen..."
          sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
          sed -i 's/#bg_BG.UTF-8 UTF-8/bg_BG.UTF-8 UTF-8/' /etc/locale.gen

          # Generate locales
          echo "Generating locales..."
          locale-gen

          # Set LANG variable
          echo "Setting LANG variable in /etc/locale.conf..."
          echo "LANG=en_US.UTF-8" > /etc/locale.conf

          # Optionally set the console keyboard layout (if needed)
          read -p "Do you want to set a console keyboard layout (e.g., bg-latin)? (y/n, default: n): " keyboard_layout_choice
          keyboard_layout_choice=${keyboard_layout_choice:-n}

          if [[ "$keyboard_layout_choice" =~ ^[Yy]$ ]]; then
              echo "Setting keyboard layout in /etc/vconsole.conf..."
              echo "KEYMAP=bg-latin" > /etc/vconsole.conf
          fi

          echo "Localization configured successfully with Europe/Sofia."
      else
          echo "Skipping localization setup."
      fi
  }

configure_localization
wait 1

configure_network() {
      read -p "Do you want to configure the network? (y/n, default: y): " network_choice
      network_choice=${network_choice:-y}  # Default to 'y' if no input is provided

      if [[ "$network_choice" =~ ^[Yy]$ ]]; then
          echo "Configuring network..."

          # Set hostname
          read -p "Enter your system hostname: " hostname
          echo "$hostname" > /etc/hostname

          # Install essential network packages
          echo "Installing essential network packages..."
          pacman -Syu --noconfirm networkmanager dhclient

          # Enable and start NetworkManager
          read -p "Do you want to enable and start NetworkManager? (y/n, default: y): " enable_network_manager
          enable_network_manager=${enable_network_manager:-y}  # Default to 'y' if no input is provided

          if [[ "$enable_network_manager" =~ ^[Yy]$ ]]; then
              systemctl enable NetworkManager
              systemctl start NetworkManager
          else
              echo "Skipping NetworkManager setup."
          fi

          # Set up DNS resolver
          echo "Configuring DNS resolver..."
          # This file typically contains nameserver settings; replace or add if necessary.
          echo "nameserver 8.8.8.8" > /etc/resolv.conf  # Google's public DNS (can be changed to preferred DNS)
          echo "nameserver 1.1.1.1" >> /etc/resolv.conf  # Cloudflare DNS (optional additional resolver)

          # Optional: Enable systemd-resolved for managing DNS
          read -p "Do you want to enable systemd-resolved for DNS management? (y/n, default: n): " resolved_choice
          resolved_choice=${resolved_choice:-n}

          if [[ "$resolved_choice" =~ ^[Yy]$ ]]; then
              pacman -Syu --noconfirm systemd-resolvconf
              systemctl enable systemd-resolved
              systemctl start systemd-resolved
              ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
              echo "Systemd-resolved enabled and configured."
          fi

          echo "Network configuration complete."
      else
          echo "Skipping network setup."
      fi
  }
configure_network

generate_initramfs() {
    read -p "Do you want to regenerate initramfs? (y/n, default: y): " initramfs_choice
    initramfs_choice=${initramfs_choice:-y}  # Default to 'y' if no input is provided

    if [[ "$initramfs_choice" =~ ^[Yy]$ ]]; then
        echo "Generating initramfs..."
        mkinitcpio -P
        echo "Initramfs generated successfully."
    else
        echo "Skipping initramfs generation."
    fi
}

generate_initramfs

set_root_password() {
    read -p "Do you want to set the root password? (y/n, default: y): " root_password_choice
    root_password_choice=${root_password_choice:-y}  # Default to 'y' if no input is provided

    if [[ "$root_password_choice" =~ ^[Yy]$ ]]; then
        echo "Setting root password..."
        passwd
        echo "Root password set successfully."
    else
        echo "Skipping root password setup."
    fi
}

set_root_password

install_boot_loader() {
    read -p "Do you want to install a boot loader? (y/n, default: y): " boot_loader_choice
    boot_loader_choice=${boot_loader_choice:-y}  # Default to 'y' if no input is provided

    if [[ "$boot_loader_choice" =~ ^[Yy]$ ]]; then
        echo "Installing boot loader..."
        
        # Install bootloader (e.g., GRUB for BIOS or UEFI systems)
        read -p "Is your system using UEFI? (y/n, default: y): " uefi_choice
        uefi_choice=${uefi_choice:-y}  # Default to 'y' if no input is provided

        if [[ "$uefi_choice" =~ ^[Yy]$ ]]; then
            pacman -S grub efibootmgr os-prober
            mkdir -p /boot/efi
            mount "$BOOT_PART" /boot/efi
            grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
            # Detect other systems and add them to the boot menu
            os-prober
            grub-mkconfig -o /boot/grub/grub.cfg
        else
            pacman -S grub os-prober
            grub-install --target=i386-pc "$DISK"
            # Detect other systems and add them to the boot menu
            os-prober
            grub-mkconfig -o /boot/grub/grub.cfg
        fi

        echo "Boot loader installed successfully. You can now choose which Arch to boot from the GRUB menu."
    else
        echo "Skipping boot loader installation."
    fi
}

  install_boot_loader
