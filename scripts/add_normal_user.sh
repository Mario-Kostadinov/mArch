#!/bin/bash
add_normal_user() {
     local username="mario"

     # Create the user 'mario' and add to 'wheel' group
     useradd -m -G wheel -s /bin/bash "$username"
     echo "User '$username' created and added to the 'wheel' group."

     # Prompt for password
     echo "Enter password for user '$username':"
     passwd "$username"

     echo "User creation and password setup complete."
 }
