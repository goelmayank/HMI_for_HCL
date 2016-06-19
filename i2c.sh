#!/bin/bash
SDA=12
SCL=13
last_byte_received=0
function set_direction {
    if [ ! $(cat /sys/class/gpio/gpio$2/direction) = $1 ]; then
        echo "$1 to /sys/class/gpio/gpio$2/direction"
        echo $1 > /sys/class/gpio/gpio$2/direction
    fi
}
function set_pins {
    for ((i=12;i<=13;i++)); do
        if [ ! -d /sys/class/gpio/gpio$i/ ]; then
            echo $i > /sys/class/gpio/export
        fi
        if [ ! $(cat /sys/class/gpio/gpio$i/direction) = "out" ]; then
            set_direction out $i
        fi
    done
}
function HIGH {
    set_direction out $SDA
    echo "1 to /sys/class/gpio/gpio$1/value"
    echo 1 > /sys/class/gpio/gpio$1/value
    sleep 0.000004
}
function LOW {
    set_direction out $SDA
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
    HIGH $SCL
    LOW $SCL
}
function checkIf_slave_acknowledges_master {
    echo "1 to /sys/class/gpio/gpio$SDA/value"
    echo 1 > /sys/class/gpio/gpio$SDA/value
    cycle $SCL
    set_direction 'in' $SDA
}
function acknowledge_slave {
    if [ ${d[8]} -eq 1 ]; then
        LOW $SDA
        cycle $SCL
        echo "Master Acknowledged Slave"
    else
        last_byte_received=1
        LOW $SDA
        cycle $SCL
        echo "Master Unacknowledged Slave"
    fi
}
function write_data {
    set_direction 'out' $SDA
    echo "Writing Data"
    for((i=0;i<8;i++)); do
        if [ ${d[i]} -eq 0 ]; then
            LOW $SDA
        else
            HIGH $SDA
        fi
        cycle $SCL
    done
    checkIf_slave_acknowledges_master
}
function read_data {
    set_direction 'in' $SDA
    echo "Receiving Data"
    for((i=0;i<8;i++)); do
        d[i]=$(cat /sys/class/gpio/gpio$SDA/value)
        cycle $SCL
        echo ${d[i]}
    done
    d[8]=$(cat /sys/class/gpio/gpio$SDA/value)
    acknowledge_slave
}
function write_message {
    echo "start"
    start
    d=(1 1 0 1 0 0 0) # 68: slave_address - ds1307 ic
    d+=('0') #adding 0 for WRITE
    echo "write_slave_address"
    write_data
    if [ $(cat /sys/class/gpio/gpio$SDA/value) -eq 0 ]; then
        echo "Slave Acknowledged Master"
        d=(0 0 0 0 0 0 0 0) # 00: word_address - Seconds command
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
    d=(1 1 0 1 0 0 0)  # 68: slave_address - ds1307 ic
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
