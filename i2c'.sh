#!/bin/bash
SDA=12
SCL=13
last_byte_received=0
function set_pins {
    for ((i=12;i<=13;i++)); do
        if [ ! -d /sys/class/gpio/gpio$i/ ]; then
            echo $i > /sys/class/gpio/export
        fi
        if [ ! $(cat /sys/class/gpio/gpio$i/direction) = "out" ]; then
            echo out > /sys/class/gpio/gpio$i/direction
            echo 1 > /sys/class/gpio/gpio$i/value
        fi
    done
}
function HIGH {
    echo "1 to /sys/class/gpio/gpio$1/value"
    echo 1 > /sys/class/gpio/gpio$1/value
    sleep 0.000004
}
function LOW {
    echo "0 to /sys/class/gpio/gpio$1/value"
    echo 0 > /sys/class/gpio/gpio$1/value
    sleep 0.0000047
}
function start {
    HIGH $SCL
    HIGH $SDA
    LOW $SDA
}
function stop {
    HIGH $SCL
    LOW $SDA
    HIGH $SDA
}
function cycle {
    echo out > /sys/class/gpio/gpio$SDA/direction
    HIGH $SCL
    LOW $SCL
}
function checkIf_slave_acknowledges_master {
    echo "1 to /sys/class/gpio/gpio$SDA/value"
    cycle $SCL
    # echo in > /sys/class/gpio/gpio$SDA/direction
}
function acknowledge_slave {
    if [ d[8] -eq 1 ]; then
        echo "0 to /sys/class/gpio/gpio$SDA/value"
        echo 0 > /sys/class/gpio/gpio$SDA/value
        echo "Master Acknowledged Slave"
    else
        last_byte_received=1
        echo "1 to /sys/class/gpio/gpio$SDA/value"
        echo 1 > /sys/class/gpio/gpio$SDA/value
        echo "Master Unacknowledged Slave"
    fi
}
function write_data {
    echo "Writing Data"
    for((i=0;i<8;i++)); do
        echo "${d[i]} to /sys/class/gpio/gpio$SDA/value"
        echo ${d[i]} > /sys/class/gpio/gpio$SDA/value
        cycle $SCL
    done
    checkIf_slave_acknowledges_master
}
function read_data {
    # echo in > /sys/class/gpio/gpio$SDA/direction
    echo "Receiving Data"
    for((i=0;i<8;i++)); do
        read -n 1 d[i]
        cycle $SCL
        printf {d[i]}
    done
    read -n 1 d[8]
    acknowledge_slave
}
function write_message {
    echo "start"
    start
    d=(1 1 0 1 0 0 0) # 68: ds1307 ic
    d+=('0') #adding 0 for WRITE
    echo "write_slave_address"
    write_data
    if [ $(cat /sys/class/gpio/gpio$SDA/value) -eq 0 ]; then
        echo "Slave Acknowledged Master"
        d=(0 0 0 0 0 0 0 0) # 00: Seconds command
        echo "write_word_address"
        write_data
        if [ $(cat /sys/class/gpio/gpio$SDA/value) -eq 0 ]; then
            echo "Slave Acknowledged Master"
            d=(1 1 0 1 0 0 0 0) #50 seconds
            echo "write_data"
            write_data
            if [ $(cat /sys/class/gpio/gpio$SDA/value) -eq 0 ]; then
                echo "Slave Acknowledged Master"
            else
                echo "Slave did not acknowledge Master"
            fi
        else
            echo "Slave did not acknowledge Master"
        fi
    else
        echo "Slave did not acknowledge Master"
        last_byte_received=1
    fi
    echo "stop"
    stop
}
function read_message {
    echo "start"
    start
    d=(1 1 0 1 0 0 0) # 68: ds1307 ic
    d+=('1') #adding 1 for READ
    echo "write_slave_address"
    write_data
    if [ $(cat /sys/class/gpio/gpio$SDA/value) -eq 0 ]; then
        echo "Slave Acknowledged Master"
        while [ $last_byte_received -eq 0 ]; do
            echo "read_data"
            read_data
        done
    fi
    echo "stop"
    stop
}

echo "set_pins"
set_pins
echo "write_message"
write_message
echo "read_message"
read_message

