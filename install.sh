echo "Starting custom intallation of Arch Linux..."
sleep 2
echo "Formatting Disk"

echo "Syncing clock..."
timedatectl set-ntp true
wait 2

#!/bin/bash

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

# Formatting
echo "Formatting partitions..."
mkfs.fat -F 32 "$BOOT_PART"
mkswap "$SWAP_PART"
mkfs.ext4 "$ROOT_PART"

# Output result
echo "Disk partitioning and formatting complete."
echo "Boot partition: $BOOT_PART"
echo "Swap partition: $SWAP_PART"
echo "Root partition: $ROOT_PART"

# Mount root partition
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
