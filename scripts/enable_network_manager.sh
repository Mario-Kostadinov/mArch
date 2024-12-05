#!/bin/bash
enable_network_manager() {
    echo "Configuring NetworkManager..."
    systemctl enable NetworkManager
    systemctl start NetworkManager

    echo "Configuring DNS resolver..."
    systemctl enable systemd-resolved
    systemctl start systemd-resolved
    ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
}
