#!/bin/bash
add_wheel_group_to_sudoers() {
    echo "Configuring sudoers to grant 'wheel' group sudo privileges..."

    # Backup the original sudoers file
    cp /etc/sudoers /etc/sudoers.bak

    # Use sed to uncomment the '%wheel ALL=(ALL) ALL' line
    echo '%wheel ALL=(ALL:ALL) ALL' | sudo EDITOR='tee -a' visudo


    echo "'wheel' group now has sudo privileges."
}
