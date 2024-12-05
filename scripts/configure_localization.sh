#!/bin/bash
configure_localization() {
    echo "Configuring localization..."

    # Uncomment the required locales in /etc/locale.gen
    echo "Uncommenting en_US.UTF-8 in /etc/locale.gen..."
    sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen

    # Generate locales
    echo "Generating locales..."
    locale-gen

    # Set LANG variable
    echo "Setting LANG variable in /etc/locale.conf..."
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
}
