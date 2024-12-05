#!/bin/bash
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
