#!/bin/bash
determine_microcode() {
    local cpu_type=$1
    case "$cpu_type" in
        AMD|amd)
            CPU_MICROCODE="amd_ucode"
            ;;
        INTEL|intel)
            CPU_MICROCODE="intel_ucode"
            ;;
        *)
            echo "Error: Unsupported CPU type. Use 'AMD' or 'INTEL'."
            return 1
            ;;
    esac
}
