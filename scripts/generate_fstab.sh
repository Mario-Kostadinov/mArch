#!/bin/bash
generate_fstab() {
      echo "Generating fstab file..."

      # Generate fstab using UUIDs (-U) and output to /mnt/etc/fstab
      genfstab -U /mnt >> /mnt/etc/fstab
      echo "fstab generated and saved to /mnt/etc/fstab."
      tail -n $(wc -l < /mnt/etc/fstab) /mnt/etc/fstab

  }
