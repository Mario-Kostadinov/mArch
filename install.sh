echo "Syncing clock..."
timedatectl set-ntp true
wait 2

partition_and_format() {
    # Ask if you want to proceed with partitioning
    read -p "Do you want to proceed with partitioning the disk? (y/n, default: y): " proceed_partition
    proceed_partition=${proceed_partition:-y}  # Default to 'y' if no input is provided

    if [[ "$proceed_partition" =~ ^[Yy]$ ]]; then
        # Prompt for disk to partition
        read -p "Enter the disk to partition (e.g., /dev/sda): " DISK

        # Default sizes
        BOOT_SIZE="1G"
        SWAP_SIZE="4G"

        # Prompt for custom boot partition size, with a default value of 1G
        read -p "Enter boot partition size (default 1G): " input_boot
        BOOT_SIZE=${input_boot:-$BOOT_SIZE}

        # Prompt for custom swap partition size, with a default value of 4G
        read -p "Enter swap partition size (default 4G): " input_swap
        SWAP_SIZE=${input_swap:-$SWAP_SIZE}

        # Start partitioning with fdisk
        echo "Partitioning $DISK with fdisk..."

        # Convert sizes to sectors for fdisk (assuming 1MiB = 2048 sectors)
        BOOT_SIZE_SECTORS=$(echo "$BOOT_SIZE" | sed 's/G//' | awk '{print $1 * 1024 * 2048}')
        SWAP_SIZE_SECTORS=$(echo "$SWAP_SIZE" | sed 's/G//' | awk '{print $1 * 1024 * 2048}')

        (
        echo g # Create a new GPT partition table
        echo n # New partition for boot
        echo 1 # Partition number 1
        echo   # Default first sector
        echo "+${BOOT_SIZE}" # Boot partition size
        echo t # Change partition type
        echo 1 # EFI System

        echo n # New partition for swap
        echo 2 # Partition number 2
        echo   # Default first sector
        echo "+${SWAP_SIZE}" # Swap partition size
        echo t # Change partition type
        echo 2 # Select partition 2
        echo 19 # Set type to Linux swap (hex code 19 for GPT)

        echo n # New partition for root
        echo 3 # Partition number 3
        echo   # Default first sector
        echo   # Use remaining space for root

        echo w # Write changes
        ) | fdisk "$DISK"

        # Identifying partitions (assuming disk is like /dev/sda)
        BOOT_PART="${DISK}1"
        SWAP_PART="${DISK}2"
        ROOT_PART="${DISK}3"

        # Prompt to format partitions (default: yes)
        read -p "Do you want to format the partitions? (y/n, default: y): " format_choice
        format_choice=${format_choice:-y}  # Default to 'y' if no input is provided

        if [[ "$format_choice" =~ ^[Yy]$ ]]; then
            echo "Formatting partitions..."
            mkfs.fat -F 32 "$BOOT_PART"
            mkswap "$SWAP_PART"
            mkfs.ext4 "$ROOT_PART"
            echo "Partition formatting complete."
        elif [[ "$format_choice" =~ ^[Nn]$ ]]; then
            echo "Skipping formatting."
        else
            echo "Invalid input. Skipping formatting."
        fi

        # Output result
        echo "Partitioning complete."
        echo "Boot partition: $BOOT_PART"
        echo "Swap partition: $SWAP_PART"
        echo "Root partition: $ROOT_PART"
    else
        echo "Skipping partitioning."
    fi
}

# Call the function
partition_and_format

# Mount root partition

  mountPartitions() {
      echo "Mounting root partition $ROOT_PART..."
      mount "$ROOT_PART" /mnt

  # Create directories for boot and other mount points
  echo "Creating and mounting boot partition $BOOT_PART..."
  mkdir -p /mnt/boot
  mount "$BOOT_PART" /mnt/boot

  # Enable swap partition
  echo "Enabling swap partition $SWAP_PART..."
  swapon "$SWAP_PART"

  echo "All partitions mounted successfully."
  }

  # Ask user whether to mount partitions
read -p "Do you want to mount the partitions? (y/n): " mount_choice
case "$mount_choice" in
    [Yy]*)
        mountPartitions
        ;;
    [Nn]*)
        echo "Skipping mounting partitions."
        ;;
    *)
        echo "Invalid choice, skipping mounting partitions."
        ;;
esac

# Descriptions for each package
DESCRIPTIONS=(
    "base: Core packages for a minimal Arch system"
    "base-devel: Development tools for building packages"
    "linux: The Linux kernel"
    "linux-firmware: Firmware for various hardware"
    "networkmanager: Simplified network management"
    "vim: Text editor"
    "grub: Bootloader"
    "efibootmgr: EFI boot manager for UEFI systems"
    "amd-ucode: AMD CPU microcode updates"
    "sudo: Allow non-root users to run commands as root"
    "git: Version control system"
    "reflector: Updates the mirrorlist for faster downloads"
    "bash-completion: Adds autocompletion to bash"
    "openssh: SSH client and server"
    "man-db: Database of manual pages"
    "man-pages: Manual pages for common programs"
    "texinfo: Documentation system for info files"
    "nvidia: Proprietary driver for NVIDIA GPUs"
    "nvidia-utils: Utilities for NVIDIA drivers"
    "nvidia-settings: Configuration tool for NVIDIA GPUs"
    "mesa: OpenGL implementation (for AMD graphics)"
)

# Function to extract package names and install them
install_packages() {
    # Extract package names from descriptions
    PACKAGE_NAMES=()
    for description in "${DESCRIPTIONS[@]}"; do
        # Extract package name before the colon
        PACKAGE_NAME=$(echo "$description" | cut -d ':' -f 1)
        PACKAGE_NAMES+=("$PACKAGE_NAME")
    done

    # List the packages and descriptions
    echo "The following packages will be installed:"
    for i in "${!PACKAGE_NAMES[@]}"; do
        echo "${DESCRIPTIONS[$i]}"
    done

    # Prompt for confirmation
    read -p "Do you want to install these packages? (y/n): " choice
    case "$choice" in
        [Yy]*)
            # Install the packages with pacstrap
            pacstrap -K /mnt "${PACKAGE_NAMES[@]}"
            echo "Installation complete."
            ;;
        [Nn]*)
            echo "Installation aborted."
            ;;
        *)
            echo "Invalid choice, installation aborted."
            ;;
    esac
}

# Call the function to install packages
install_packages

generate_fstab() {
      echo "Generating fstab file..."

      # Generate fstab using UUIDs (-U) and output to /mnt/etc/fstab
      genfstab -U /mnt >> /mnt/etc/fstab
      echo "fstab generated and saved to /mnt/etc/fstab."
      tail -n $(wc -l < /mnt/etc/fstab) /mnt/etc/fstab

  }
  generate_fstab

chroot_into_system() {
      read -p "Do you want to chroot into the new system? (y/n, default: y): " chroot_choice
      chroot_choice=${chroot_choice:-y}  # Default to 'y' if no input is provided

      if [[ "$chroot_choice" =~ ^[Yy]$ ]]; then
          echo "Chrooting into the new system..."
          arch-chroot /mnt
      else
          echo "Skipping chroot into the new system."
      fi
  }

chroot_into_system
wait 1

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
            pacman -S grub efibootmgr
            mkdir -p /boot/efi
            mount "$BOOT_PART" /boot/efi
            grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
            grub-mkconfig -o /boot/grub/grub.cfg
        else
            pacman -S grub
            grub-install --target=i386-pc "$DISK"
            grub-mkconfig -o /boot/grub/grub.cfg
        fi

        echo "Boot loader installed successfully."
    else
        echo "Skipping boot loader installation."
    fi
}

install_boot_loader
