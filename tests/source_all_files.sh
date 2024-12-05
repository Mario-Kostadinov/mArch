#!/bin/bash
for FILE in ~/mos/dist/scripts/* ; do source $FILE ; done

determine_microcode "AMD"

echo $CPU_MICROCODE
