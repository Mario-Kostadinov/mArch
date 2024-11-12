run_mos_script() {
    local chroot_script="test-chroot.sh"

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

run_mos_script
