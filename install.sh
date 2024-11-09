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

# Start partitioning
echo "Partitioning $DISK..."
wait 1
parted -s "$DISK" mklabel gpt
parted -s "$DISK" mkpart ESP fat32 1MiB "$BOOT_SIZE"
parted -s "$DISK" set 1 esp on
parted -s "$DISK" mkpart primary linux-swap "$BOOT_SIZE" "$(($BOOT_SIZE + $SWAP_SIZE))"
parted -s "$DISK" mkpart primary ext4 "$(($BOOT_SIZE + $SWAP_SIZE))" 100%

# Identifying partitions
BOOT_PART="${DISK}1"
SWAP_PART="${DISK}2"
ROOT_PART="${DISK}3"

# Formatting
echo "Formatting partitions..."
wait 1
mkfs.fat -F 32 "$BOOT_PART"
mkswap "$SWAP_PART"
mkfs.ext4 "$ROOT_PART"

# Output result
echo "Disk partitioning and formatting complete."
echo "Boot partition: $BOOT_PART"
echo "Swap partition: $SWAP_PART"
echo "Root partition: $ROOT_PART"
