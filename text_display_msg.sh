#!/bin/bash
a=(77 76 75 74 73 72 71 70 78 78)
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
write_command
function write_data {
    for((i=$1;i<$2;i++)); do
        echo ${b[i]} > /sys/class/gpio/gpio${a[((i%10))]}/value
    done
}
statement=$(cat msg.txt)
echo 1 > /sys/class/gpio/gpio79/value
echo 0 > /sys/class/gpio/gpio80/value

b=()   
c=0
for((i=0;i<${#statement};i++)); do
    decimal=$(printf '%d' "'${statement:i:1}")
    let "mask = 0x80" #10000000
    while [ "$mask" -gt 0 ]; do
        if [ $((decimal & mask)) -gt 0 ]; then
        	b[((c++))]=1
        else
        	b[((c++))]=0
        fi
        let "mask >>= 1" # move the bit down 
    done 
    b[((c++))]=1
    b[((c++))]=0
done
length=$((${#statement}*10))
if [ $length -le 200 ]; then
    write_data 0 $length
elif [[ $length -gt 200 && $length -le 400 ]]; then
    write_data 0 200
    echo 0 > /sys/class/gpio/gpio79/value
    d=(1 1 0 0 0 0 0 0 1 0) #C0
    execute_command
    echo 1 > /sys/class/gpio/gpio79/value
    write_data 200 $length
else
    echo "Character of bound"
fi
