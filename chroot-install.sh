prompt_confirmation() {
    local question="$1"
    local callback="$2"
    read -p "$question (y/n): " choice
    case "$choice" in
        [Yy]*) 
            # Call the passed function
            "$callback"
            ;;
        [Nn]*) 
            echo "Skipping Operation..."
            ;;
        *) 
            echo "Invalid choice, please answer y or n."
            ;;
    esac
}

set_time_zone() {
    echo "Setting the time zone to Europe/Sofia..."

    # Set the time zone to Europe/Sofia
    ln -sf "/usr/share/zoneinfo/Europe/Sofia" /etc/localtime

    echo "Generating hardware clock settings..."
    hwclock --systohc

    # Setting up time synchronization (systemd-timesyncd)
    echo "Enabling NTP for time synchronization..."
    systemctl enable systemd-timesyncd
    systemctl start systemd-timesyncd

    echo "Time zone and synchronization set successfully."
}

prompt_confirmation "Do you want to set time zone" set_time_zone

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

createUser() {
    # Prompt for username
    read -p "Enter the username to create: " username

    # Create the user and add to 'wheel' group
    useradd -m -G wheel -s /bin/bash "$username"
    echo "User '$username' created and added to the 'wheel' group."

    # Prompt for password
    echo "Enter password for user '$username':"
    passwd "$username"

    echo "User creation and password setup complete."
}

prompt_confirmation "Do you want to add a user" createUser

configureSudoers() {
    echo "Configuring sudoers to grant 'wheel' group sudo privileges..."

    # Backup the original sudoers file
    cp /etc/sudoers /etc/sudoers.bak

    # Use sed to uncomment the '%wheel ALL=(ALL) ALL' line
    sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

    echo "'wheel' group now has sudo privileges."
}

prompt_confirmation "Do you want to configure Sudoers?" configureSudoers

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

    # Ask whether to install a boot loader
    read -p "Do you want to install a boot loader? (y/n, default: y): " boot_loader_choice
    boot_loader_choice=${boot_loader_choice:-y}  # Default to 'y' if no input is provided

    if [[ "$boot_loader_choice" =~ ^[Yy]$ ]]; then
        echo "Installing boot loader..."
        echo "Select installation type:"
        echo "1) USB Installation"
        echo "2) Existing OS Installation"
        read -p "Enter your choice (1/2, default: 1): " installation_type
        installation_type=${installation_type:-1}  # Default to '1' if no input

        # Install bootloader (e.g., GRUB for BIOS or UEFI systems)
        read -p "Is your system using UEFI? (y/n, default: y): " uefi_choice
        uefi_choice=${uefi_choice:-y}  # Default to 'y' if no input is provided

        if [[ "$uefi_choice" =~ ^[Yy]$ ]]; then
            pacman -S grub efibootmgr os-prober

            grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

            if [[ "$installation_type" == "1" ]]; then
                grub-mkconfig -o /boot/grub/grub.cfg
            fi

        fi

        echo "Boot loader installed successfully. You can now choose which Arch to boot from the GRUB menu."
    else
        echo "Skipping boot loader installation."
    fi
}

  install_boot_loader
