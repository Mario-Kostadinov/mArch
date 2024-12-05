#!/bin/bash
mount_partitions() {
    mount "$ROOT_PART" /mnt
    mkdir -p /mnt/boot/efi
    mount "$BOOT_PART" /mnt/boot/efi
    swapon "$SWAP_PART"
}
