#!/bin/bash
echo in > /sys/class/gpio/gpio45/direction
currentState=`cat /sys/class/gpio/gpio45/value`
prevState=$currentState
i=0
echo interrupt_PID=$$
blink_Pid=`cat /tmp/blink_pid` 
echo $blink_Pid
while [ 1 ]
do
    currentState=`cat /sys/class/gpio/gpio45/value`
    if [ $currentState -ne $prevState ]
    then
        echo Interrupt No. $((++i))
        echo Current State $currentState
        #echo in > /sys/class/gpio/gpio44/direction
        # echo "Waiting for 3 sec"
        # sleep 3
        if [ -f /tmp/blink_pid ]; then
            echo "Sending interrupt to blink"
            kill -3 $blink_Pid
            echo "Interrupt sent to blink"
        fi
        # echo "3 sec over"
        #echo out > /sys/class/gpio/gpio44/direction
    fi
    prevState=$currentState
done
