#!/bin/bash
a=(77 76 75 74 73 72 71 70 78 78)
d=()
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
      echo ${d[i]} > /sys/class/gpio/gpio${a[i]}/value
    done
}
function write_command {
    echo 0 > /sys/class/gpio/gpio79/value
    echo 0 > /sys/class/gpio/gpio80/value
    d=(0 0 1 1 1 0 0 0 1 0) #38
    execute_command 
    d=(0 0 0 0 1 1 0 0 1 0) #0C
    execute_command 
    d=(0 0 0 0 0 0 0 1 1 0) #01
    execute_command 
    d=(1 0 0 0 0 0 0 0 1 0) #80
    execute_command
}
function write_data {
    for((i=0;i<200;i++)); do
        echo ${d[i]} > /sys/class/gpio/gpio${a[((i%10))]}/value
    done
}
function write_data {
    for((i=0;i<200;i++)); do
        echo ${d[i]} > /sys/class/gpio/gpio${a[((i%10))]}/value
    done
}
set_pins
write_command

date +%s > c.txt 
date +%N >> c.txt
statement=$(cat input.txt)

echo 1 > /sys/class/gpio/gpio79/value
echo 0 > /sys/class/gpio/gpio80/value

d=()   
c=0
for((i=0;i<40;i++)); do
    decimal=$(printf '%d' "'${statement:i:1}")
    let "mask = 0x80" #10000000
    while [ "$mask" -gt 0 ]; do
        if [ $((decimal & mask)) -gt 0 ]; then
        	d[((c++))]=1
        else
        	d[((c++))]=0
        fi
        let "mask >>= 1" # move the bit down 
    done 
    d[((c++))]=1
    d[((c++))]=0
done
write_data

date +%s >> c.txt 
date +%N >> c.txt

