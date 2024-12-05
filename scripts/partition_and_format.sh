#!/bin/bash
partition_and_format() {
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
    BOOT_PART="${DISK}p1"
    SWAP_PART="${DISK}p2"
    ROOT_PART="${DISK}p3"

    # Prompt to format partitions (default: yes)
    echo $BOOT_PART
    echo $SWAP_PART
    echo $ROOT_PART
    mkfs.fat -F 32 "$BOOT_PART"
    mkswap "$SWAP_PART"
    mkfs.ext4 "$ROOT_PART"
}
