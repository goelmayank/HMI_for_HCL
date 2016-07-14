#!/bin/bash
. set_pins.sh
flag=0
echo "User Mode: Press Mode buttons for 3 sec." > msg.txt
. text_display_msg.sh
while [ 1 ]; do
    modeUp=$(cat /sys/class/gpio/gpio66/value)
    modeDown=$(cat /sys/class/gpio/gpio68/value)
    if [[ ($modeUp -eq 0) && $modeDown -eq 0 ]]; then
        if [ $flag -eq 0 ]; then
            SECONDS=0
        fi
        flag=1
    elif [ $flag -eq 1 ]; then
        if [ $SECONDS -ge 3 ]; then
            echo "Entering User Mode"
            . usermode.sh 
        fi
        flag=0 
    fi
done
exit 0
