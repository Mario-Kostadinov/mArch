generate_ssh_key() {
    # Set default key name
    local key_name="id_rsa"

    # Ensure the .ssh directory exists
    mkdir -p /home/mario/.ssh
    chmod 700 /home/mario/.ssh

    # Check if the key file already exists
    if [[ -f "/home/mario/.ssh/$key_name" ]]; then
        echo "Error: SSH key '$key_name' already exists in /home/mario/.ssh/"
        return 1
    fi

    # Generate the SSH key without passphrase
    echo "Generating SSH key '$key_name' in /home/mario/.ssh/..."
    ssh-keygen -t rsa -b 4096 -C "" -f "/home/mario/.ssh/$key_name" -N ""

    # Set correct ownership and permissions
    chown -R mario:mario /home/mario/.ssh
    chmod 600 /home/mario/.ssh/$key_name
    chmod 644 /home/mario/.ssh/$key_name.pub

    # Print success message
    echo "SSH key '$key_name' generated successfully!"
    echo "Public key: "
    cat "/home/mario/.ssh/$key_name.pub"
}
