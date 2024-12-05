enable_time_sync() {
    echo "Enabling syncing clock with Internet"
    timedatectl set-ntp true
}
