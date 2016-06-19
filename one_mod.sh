#!/bin/bash
a=(70 71 72 73 74 75 76 77) #one_by_one
function set_pins {
    for ((i=70;i<=80;i++)) do
        if [ ! -d /sys/class/gpio/gpio$i/ ]; then
            echo $i > /sys/class/gpio/export
        fi
        if [ ! $(cat /sys/class/gpio/gpio$i/direction) = "out" ]; then
            echo out > /sys/class/gpio/gpio$i/direction
        fi
    done
}
function execute_command {
  for((i=0;i<8;i++)); do
      echo ${d[i]} > /sys/class/gpio/gpio${a[i]}/value
  done
  echo 0 > /sys/class/gpio/gpio79/value
    echo 0 > /sys/class/gpio/gpio80/value
    echo 1 > /sys/class/gpio/gpio78/value
    sleep 0.00045
    echo 0 > /sys/class/gpio/gpio78/value
}
function write_command {
    d=(0 0 1 1 1 0 0 0) #38
    execute_command 
    d=(0 0 0 0 1 1 0 0) #0C
    execute_command 
    d=(0 0 0 0 0 0 0 1) #01
    execute_command 
    # d=(0 0 0 0 0 1 1 0) #06
    # execute_command 
    d=(1 0 0 0 0 0 0 0) #80
    execute_command
}
set_pins
write_command
TS1=`date +%s`
TS2=`date +%N`
statement=$(cat input.txt)
echo 1 > /sys/class/gpio/gpio79/value
echo 0 > /sys/class/gpio/gpio80/value
for((index=0;index<40;index++)); do
    character="${statement:$index:1}"
    decimal=$(printf '%d' "'$character")
    for((j=0;j<8;j++)); do
        echo $((decimal%2)) > /sys/class/gpio/gpio${a[j]}/value
        ((decimal/=2))
    done
    echo 1 > /sys/class/gpio/gpio78/value
    # sleep 0.00045
    echo 0 > /sys/class/gpio/gpio78/value
done
TE1=`date +%s`
TE2=`date +%N`

SEC=`expr $TE1 - $TS1`
echo "SEC=$SEC"
NS=$((SEC*1000000000))
echo "NS=$NS"
NSE=`expr $TE2 + $NS`
echo "NSE=$NSE"
TIME=`expr $NSE - $TS2`
echo $TIME
# TT=$((TIME/1000000000))
# echo "Total time=$TT sec"
