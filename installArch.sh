#!/bin/bash
source ./.env.sample
for FILE in ./scripts/* ; do source $FILE ; done

disk() {
    echo "Starting Partitining of $DISK"
    wait 3
    partition_and_format
    echo "Partitioning complete."
    echo "Boot partition: $BOOT_PART"
    echo "Swap partition: $SWAP_PART"
    echo "Root partition: $ROOT_PART"
    echo "Starting mouting partitions..."
    wait 3
    mount_partitions
    echo "Generating fstab"
    wait 3
}

diskManual() {
    prompt_confirmation "Do you want to partition and format $DISK?" partition_and_format

    prompt_confirmation "Do you want to mount partitions?" mount_partitions
}

manual_install_base_apps() {
    determine_microcode $CPU
    install_packages_with_pacstrap $BASE_APPS $CPU_MICROCODE
}

baseInstallAutomatic() {
      echo "Starting base Arch install..."
      wait 3
      disk
      echo "Finished formatting disk"
      wait 3
      echo "Installing base packages"
      wait 3
      determine_microcode $CPU
      install_packages_with_pacstrap $BASE_APPS $CPU_MICROCODE
      generate_fs_tab
      copy_repo_to_root
  }

baseInstallManual() {
    prompt_confirmation "Do you want to format and partition disk?" diskManual
    determine_microcode $CPU

    prompt_confirmation "Do you want to install base packages?" manual_install_base_apps
    prompt_confirmation "Do you want to generate fstab?" generate_fstab
    prompt_confirmation "Do you want to copy repo to roo?" copy_repo_to_root
}

networkAutomatic(){
    configure_hostname
    install_network_manager
    enable_network_manager
}

network_manual() {
    prompt_confirmation "Do you want to configure hostname?" configure_hostname
    prompt_confirmation "Do you want to install network manager?" install_network_manager
    prompt_confirmation "Do you want to enable network manager?" enable_network_manager
}

chrootInstallManual() {
    prompt_confirmation "Do you want to configure network?" network_manual
    prompt_confirmation "Do you want to confugure localisation?" configure_localisation
    prompt_confirmation "Do you want to add a normal user?" add_normal_user
    prompt_confirmation "Do you want to add normal user permissions?" add_normal_user_ownership
    prompt_confirmation "Do you want to set time zone?" set_time_zone
    prompt_confirmation "Do you want to add root user password?" update_sudo_user 
    prompt_confirmation "Do you want to add normal user to wheel group?" add_wheel_group_to_sudoers
    prompt_confirmation "Do you want to generate initramfs?" generate_initramfs
    prompt_confirmation "Do you want to install grub bootloader apps?" install_grub_boot_loader_apps
    prompt_confirmation "Do you want to install grub bootloader?" install_grub_boot_loader
}

setup_display_manager() {
   prompt_confirmation "Do you want to install Display Manager?" install_sddm
   prompt_confirmation "Do you want to enable Display Manager?" enable_sddm
}

setup_qtile() {
  prompt_confirmation "Do you want to install qtile?" install_qtile
  prompt_confirmation "Do you want to copy qtile config?" copy_qtile_config
  prompt_confirmation "Do you want to copy qtile autostart script?" copy_qtile_autostart
}

setup_window_manager() {
  prompt_confirmation "Do you want to setup qtile?" setup_qtile 
}

setup_keybindings(){
   prompt_confirmation "Do you want to install X11 Keybindings?" X11_keybindings_install
   prompt_confirmation "Do you want to swap ctrl caps?" swap_ctrl_caps_permanent
   prompt_confirmation "Do you want to copy X11 Keybindings?" copy_X11_keybindings
}

setup_terminal_emulator() {
 prompt_confirmation "Do you want to install alacritty?" install_alacritty
 prompt_confirmation "Do you want to copy alacritty config?" copy_alacritty_config
}

setup_yay(){
  prompt_confirmation "Do you want to install yay?" install_yay  
}

install_ides() {
  install_apps_individually $APPLICATIONS_DEV_IDES
}

setup_ides() {
  prompt_confirmation "Do you want to install ides?" install_ides
  prompt_confirmation "Do you want to copy emacs setup?" copy_emacs_config
}

install_apps() {
  install_apps_individually $APPLICATIONS_DEV
  install_yay_apps $APPLICATIONS_DEV_YAY
  install_apps_individually $APPLICATIONS_UTILITY
  install_yay_apps $APPLICATIONS_UTILITY_YAY
  install_apps_individually $APPLICATIONS_BROWSERS
  install_yay_apps $APPLICATIONS_BROWSERS_YAY
}

desktop_install_manual() {
   prompt_confirmation "yay setup?" setup_yay
   prompt_confirmation "Install Applications" install_apps
   prompt_confirmation "Generate SSH key?" generate_ssh_key
   prompt_confirmation "Display Manager setup?" setup_display_manager 
   prompt_confirmation "Window Manager setup?" setup_window_manager
   prompt_confirmation "Keybindings Setup?" setup_keybindings
   prompt_confirmation "Terminal Emulator setup?" setup_terminal_emulator
   prompt_confirmation "IDEs setup?" setup_ides
}

desktopInstall(){
    install_apps $APPLICATIONS_BROWSERS
    install_apps $APPLICATIONS_DEV
}

# Main menu function
main() {
    echo "Select an installation step:"
    echo "1. Base Install (automatic)"
    echo "2. Base Install (manual)"
    echo "3. Chroot Install (automatic)"
    echo "4. Chroot Install (manual)"
    echo "5. Desktop Install (automatic)"
    echo "6. Desktop Install (manual)"
    echo "0. Exit"

    read -rp "Enter your choice [1-3 or 0]: " choice
    case "$choice" in
        1)
            baseInstallAutomatic
            ;;
        2)
            baseInstallManual
            ;;
        3)
            chrootInstallAutomatic
            ;;
        4)
            chrootInstallManual
            ;;
        5)
            desktopInstallAutomatic
            ;;
        6)
            desktop_install_manual
            ;;

        0)
            echo "Exiting installation script. Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid choice. Please select 1, 2, 3, or 0."
            ;;
    esac
}

main
