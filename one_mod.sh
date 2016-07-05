#!/bin/bash
a=(70 71 72 73 74 75 76 77 78 78)
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
  for((i=0;i<10;i++)); do
    #   echo "${d[i]} to /sys/class/gpio/gpio${a[i]}/value"
      echo ${d[i]} > /sys/class/gpio/gpio${a[i]}/value
  done
}
function write_command {
    echo 0 > /sys/class/gpio/gpio80/value #for_write
    echo 0 > /sys/class/gpio/gpio79/value #for_command
    d=(0 0 0 1 1 1 0 0 1 0) #38
    execute_command 
    d=(0 0 1 1 0 0 0 0 1 0) #0C
    execute_command 
    d=(1 0 0 0 0 0 0 0 1 0) #01
    execute_command 
    d=(0 0 0 0 0 0 0 1 1 0) #80
    execute_command
}
set_pins
write_command
statement=$(cat input.txt)
function write_data {
    echo 1 > /sys/class/gpio/gpio79/value
    for((index=$1;index<$2;index++)); do
        character="${statement:$index:1}"
        decimal=$(printf '%d' "'$character")
        for((j=0;j<8;j++)); do
            echo $((decimal%2)) > /sys/class/gpio/gpio${a[j]}/value
            ((decimal/=2))
        done
        echo 1 > /sys/class/gpio/gpio78/value
        echo 0 > /sys/class/gpio/gpio78/value
    done
}
write_data 0 20
echo 0 > /sys/class/gpio/gpio79/value
d=(0 0 0 0 0 0 1 1 1 0) #C0
execute_command
write_data 20 40