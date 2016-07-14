#!/bin/bash
echo out > /sys/class/gpio/gpio44/direction
echo "Writing pid of Blink.sh to blink_pid"
echo $$ > /tmp/blink_pid
echo blink_pid=$$
echo "pid of Blink.sh written to blink_pid"

function hang_up {
    echo "Waiting for 3 sec"
    sleep 5
    echo "3 sec over"
}

trap hang_up 1 2 3 9 11 15 18 19

state=`cat /sys/class/gpio/gpio44/value`

while [ 1 ]
do
    sleep 0.5
	if [ $state -eq 0 ]
	then
		state=1
		echo "State = $state"
	else
		state=0
		echo "State = $state"
   	fi
    echo $state > /sys/class/gpio/gpio44/value
done


