prompt_confirmation() {
    local question="$1"
    local callback="$2"
    shift 2 # Shift the first two arguments to access remaining arguments
    local args=("$@") # Store remaining arguments in an array

    read -p "$question (y/n): " choice
    case "$choice" in
        [Yy]*) 
            # Call the passed function with the remaining arguments
            "$callback" "${args[@]}"
            ;;
        [Nn]*) 
            echo "Skipping Operation..."
            ;;
        *) 
            echo "Invalid choice, please answer y or n."
            ;;
    esac
}

installApps() {
    # Retrieve the list of applications passed as an argument
    local apps=("$@")

    # Install each app using pacman
    for app in "${apps[@]}"; do
        # Extract the app name (before the colon)
        app_name=$(echo "$app" | cut -d ':' -f 1)
        echo "Installing $app_name..."
        sudo pacman -S --noconfirm "$app_name"
    done

    echo "All apps have been installed."
}

  run_mos_script() {
      local chroot_script="mos.sh"

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

APPS=(
    #timetracking
    "timew: cli base time tracking app"
    "rofi: menu"
    "sxhkd: Simple X hotkey daemon"
    #terminal emulator
    "alacritty: A fast, cross-platform, OpenGL terminal emulator"
    #browsers
    "firefox: browser"
    "rg: recursively search the current dir for lines matching a pattern"
)

APPS_DEV_EDITORS=(
    "emacs: GNU project Emacs editor"
    "vim: Vi IMproved, a programmer's text editor"
    "code: Microsoft's code editor - vscode"
    "nano: simple text editor"
)

prompt_confirmation "Do you want to install base applications" installApps "${APPS[@]}"

prompt_confirmation "Do you want to install Dev Editors?" installApps "${APPS_DEV_EDITORS[@]}"

YAY_APPS=(
    "google-chrome: stupid browser"
)

install_yay() {
    # Ensure base-devel is installed
    echo "Installing base-devel group (if not already installed)..."
    sudo pacman -S --needed base-devel

    # Create a directory for the build if it doesn't exist
    if [ ! -d "$HOME/Downloads" ]; then
        mkdir -p "$HOME/Downloads"
    fi

    # Change to the Downloads directory
    cd "$HOME/Downloads" || { echo "Failed to enter Downloads directory"; return 1; }

    # Clone the yay repository if it doesn't exist
    if [ ! -d "yay-bin" ]; then
        echo "Cloning yay AUR repository..."
        git clone https://aur.archlinux.org/yay-bin.git
    else
        echo "yay-bin directory already exists. Skipping clone."
    fi

    # Change to the yay directory and build the package
    cd yay-bin || { echo "Failed to enter yay-bin directory"; return 1; }

    echo "Building and installing yay..."
    makepkg -si

    echo "yay installation complete."
}
prompt_confirmation "Do you want to install YaY?" install_yay

install_yay_apps() {
 for app in "${YAY_APPS[@]}"; do
     # Extract the app name before the colon
     app_name="${app%%:*}"

     echo "Installing $app_name..."
     yay -S --noconfirm "$app_name" || {
         echo "Failed to install $app_name. Please check the package name and try again."
     }
 done
}


prompt_confirmation "Do you want to install YaY applications?" install_yay_apps

installSDDM() {
    echo "Installing SDDM..."
    pacman -S --noconfirm sddm
    echo "SDDM installation complete."
}

configureSDDM() {
    systemctl enable sddm
}

installSDDMFresh() {
 installSDDM
}

prompt_confirmation "Do you want to install SDDM" installSDDMFresh
prompt_confirmation "Do you want to enable SDDM" configureSDDM

swap_ctrl_caps_permanent() {
    echo "Copying ctrl:swapcaps configuration..."

    # Define source and target paths
    src="/home/mario/mArch/configs/00-keyboard.conf"
    dest="/etc/X11/xorg.conf.d/00-keyboard.conf"

    # Create target directory if it doesn't exist
    mkdir -p "$(dirname "$dest")"

    # Copy the configuration file
    if cp "$src" "$dest"; then
        echo "ctrl:swapcaps configuration copied to $dest successfully."
    else
        echo "Error: Failed to copy ctrl:swapcaps configration from $src to $dest."
    fi
  }

prompt_confirmation "Do you wanto swap caps and control?" swap_ctrl_caps_permanent

installQtile() {
 pacman -S --noconfirm qtile
}

copyQtileConfig() {
    echo "Copying Qtile configuration file..."
    local source="/home/mario/mArch/configs/qtile.py"
    local target="/home/mario/.config/qtile/config.py"
    mkdir -p "$(dirname "$target")"

    # Copy the configuration file from 'configs/qtile.py' to the target directory
    cp "$source" "$target"

    echo "Qtile configuration file copied to ~/.config/qtile/config.py."
}

installAndConfigureQtile(){
   installQtile
   copyQtileConfig
}

prompt_confirmation "Do you want to install Qtile" installAndConfigureQtile

prompt_confirmation "Do you want to update Qtile Configuration" copyQtileConfig

copyEmacsConfig() {
    echo "Copying Emacs configuration..."

    # Define source and target paths
    src="/home/mario/mArch/configs/EmacsConfig.el"
    dest="/home/mario/.emacs.d/init.el"

    # Create target directory if it doesn't exist
    mkdir -p "$(dirname "$dest")"

    # Copy the configuration file
    if cp "$src" "$dest"; then
        echo "Emacs configuration copied to $dest successfully."
    else
        echo "Error: Failed to copy Emacs configuration from $src to $dest."
    fi
}
prompt_confirmation "Do you want to copy Emacs config?" copyEmacsConfig

copyAlacrittyConfig() {
    echo "Copying Alacritty configuration..."

    # Define source and target paths
    src="/home/mario/mArch/configs/alacritty.toml"
    dest="/home/mario/.config/alacritty/alacritty.toml"

    # Create target directory if it doesn't exist
    mkdir -p "$(dirname "$dest")"

    # Copy the configuration file
    if cp "$src" "$dest"; then
        echo "Alacritty configuration copied to $dest successfully."
    else
        echo "Error: Failed to copy Alacritty configration from $src to $dest."
    fi
}

prompt_confirmation "Do you want to copy Alacritty configration?" copyAlacrittyConfig

CALLFLOW_IPS="10.10.160.20 jaeger-bacb.omnilinx.com
10.10.160.20 app-stage.omnilinx.dev
10.10.160.20 sso-stage.omnilinx.dev
10.10.160.20 api-stage.omnilinx.dev
10.10.160.20 pgadmin4.omnilinx.com
10.10.160.20 mongo-express.omnilinx.com
10.10.160.20 kube-dashboard.omnilinx.com
10.10.160.20 graylog.omnilinx.com
10.10.160.20 pgadmin4-stage.omnilinx.dev
10.10.160.20 jenkins.omnilinx.com
10.10.210.22 dev-unify.callflowlab.com
10.10.110.116 omnilinxdev.callflowlab.com
10.10.160.20 sso.omnilinx.dev
10.10.160.20 sso.omnilinx.com
10.10.160.20 api.omnilinx.dev
10.10.160.20 app.omnilinx.dev
10.10.160.20 allianz.omnilinx.dev
10.10.160.20 mongo-express-stage.omnilinx.dev
127.0.0.1 allianzz.omnilinx.dev
10.10.160.20 swagger-ui.omnilinx.dev
10.10.160.20 livechat-testing-page.omnilinx.dev
10.10.160.20 nexus.omnilinx.com
10.10.160.20 pgadmin4.omnilinx.dev
10.10.160.20 jaeger.omnilinx.com
10.10.160.20 jaeger.omnilinx.dev
10.10.160.20 jaeger-stage.omnilinx.dev
10.10.160.20 rabbitmq.omnilinx.dev
10.10.160.20 mongo-express.omnilinx.dev
10.10.160.20 graylog.omnilinx.com"

overwriteHosts() {
    # Write to /etc/hosts, starting with localhost entry
    echo -e "127.0.0.1 localhost\n$CALLFLOW_IPS" | sudo tee /etc/hosts > /dev/null

    echo "Entries have been written to /etc/hosts."
}

prompt_confirmation "Do you want to configure etc/hosts" overwriteHosts


