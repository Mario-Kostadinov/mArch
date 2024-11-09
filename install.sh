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

# Function to copy and execute post-chroot script
run_chroot_install() {
    local chroot_script="chroot-install.sh"

    # Check if the script exists
    if [[ -f "$chroot_script" ]]; then
        echo "Copying $chroot_script to /mnt/root/..."
        cp "$chroot_script" /mnt/root/
        chmod +x /mnt/root/$chroot_script

        echo "Entering chroot and executing $chroot_script..."
        arch-chroot /mnt /root/$chroot_script
    else
        echo "Error: $chroot_script not found. Please ensure the script is in the same directory."
        exit 1
    fi
}

# Call the function to copy and execute the chroot script
run_chroot_install
