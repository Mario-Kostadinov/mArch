prompt_confirmation() {
    local question="$1"
    local callback="$2"
    read -p "$question (y/n): " choice
    case "$choice" in
        [Yy]*) 
            # Call the passed function
            "$callback"
            ;;
        [Nn]*) 
            echo "Skipping Operation..."
            ;;
        *) 
            echo "Invalid choice, please answer y or n."
            ;;
    esac
}

APPS=(
    #timetracking
    "timew: cli base time tracking app"
    "rofi: menu"
    #terminal emulator
    "alacritty: A fast, cross-platform, OpenGL terminal emulator"
)

installApps() {
  # Install each app using pacman
  for app in "${APPS[@]}"; do
      # Extract the app name (before the colon)
      app_name=$(echo "$app" | cut -d ':' -f 1)
      echo "Installing $app_name..."
      sudo pacman -S --noconfirm "$app_name"
  done

  echo "All apps have been installed."
}
prompt_confirmation "Do you want to install base applications" installApps

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

installQtile() {
 pacman -S --noconfirm qtile
}

copyQtileConfig() {
    echo "Copying Qtile configuration file..."

    # Copy the configuration file from 'configs/qtile.py' to the target directory
    cp "$(dirname "$0")/configs/qtile.py" ~/.config/qtile/config.py

    echo "Qtile configuration file copied to ~/.config/qtile/config.py."
}

installAndConfigureQtile(){
   installQtile
   copyQtileConfig
}

prompt_confirmation "Do you want to install Qtile" installAndConfigureQtile

prompt_confirmation "Do you want to update Qtile Configuration" copyQtileConfig

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
