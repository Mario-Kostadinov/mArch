#!/bin/bash
source ~/mos/dist/scripts/copyEmacsConfig.sh
source ~/mos/dist/scripts/install_apps.sh

echo "What would you like to update?"

# Define the list of options and their corresponding functions
declare -A actions
actions["emacs"]="copyEmacsConfig"
actions["qtile"]="runQtile"
actions["network"]="runNetwork"
actions["firewall"]="runFirewall"
actions["docker"]="runDocker"
actions["kubernetes"]="runKubernetes"

runQtile() {
    echo "Configuring Qtile..."
}

runNetwork() {
    echo "Setting up network..."
}

runFirewall() {
    echo "Configuring firewall..."
}

runDocker() {
    echo "Managing Docker containers..."
}

runKubernetes() {
    echo "Deploying Kubernetes cluster..."
}

# Display all options with numbers
listOptions() {
    echo "Available options:"
    i=1
    for option in "${!actions[@]}"; do
        echo "$i. $option"
        ((i++))
    done
}

# Main loop
while true; do
    echo
    echo "Choose an action:"
    echo "1. List all options and select by number"
    echo "2. Search for an option"
    echo "3. Exit"
    read -p "Enter your choice (1-3): " main_choice

    case $main_choice in
        1)
            listOptions
            read -p "Enter the number corresponding to your choice: " number_choice

            if [[ "$number_choice" =~ ^[0-9]+$ ]]; then
                option_index=$((number_choice - 1))
                selected_option=$(echo "${!actions[@]}" | tr ' ' '\n' | sed -n "$((option_index + 1))p")

                if [[ -n "$selected_option" ]]; then
                    echo "You selected: $selected_option"
                    read -p "Do you want to execute the action for $selected_option? (y/n): " confirm
                    if [[ "$confirm" == "y" ]]; then
                        "${actions[$selected_option]}"
                    else
                        echo "Action for $selected_option canceled."
                    fi
                else
                    echo "Invalid number. Please try again."
                fi
            else
                echo "Invalid input. Please enter a number."
            fi
            ;;
        2)
            # Search for an option
            read -p "Enter a keyword: " user_input
            matches=()
            for option in "${!actions[@]}"; do
                if [[ "$option" == *"$user_input"* ]]; then
                    matches+=("$option")
                fi
            done

            if [ ${#matches[@]} -eq 0 ]; then
                echo "No matches found for: $user_input."
            else
                echo "Potential matches:"
                for i in "${!matches[@]}"; do
                    echo "$((i + 1)). ${matches[$i]}"
                done

                read -p "Select a number from the list above: " match_choice
                if [[ "$match_choice" =~ ^[0-9]+$ ]] && (( match_choice >= 1 && match_choice <= ${#matches[@]} )); then
                    selected_match="${matches[$((match_choice - 1))]}"
                    echo "You selected: $selected_match"
                    read -p "Do you want to execute the action for $selected_match? (y/n): " confirm
                    if [[ "$confirm" == "y" ]]; then
                        "${actions[$selected_match]}"
                    else
                        echo "Action for $selected_match canceled."
                    fi
                else
                    echo "Invalid choice. Please try again."
                fi
            fi
            ;;
        3)
            echo "Goodbye!"
            break
            ;;
        *)
            echo "Invalid choice. Please select 1, 2, or 3."
            ;;
    esac
done
