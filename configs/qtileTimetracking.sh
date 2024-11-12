#!/bin/bash

TASK=$(timew | awk 'NR==1')
OUTPUT=$(timew | awk 'NR==4')
echo $TASK - $OUTPUT
# echo "Hello world"
