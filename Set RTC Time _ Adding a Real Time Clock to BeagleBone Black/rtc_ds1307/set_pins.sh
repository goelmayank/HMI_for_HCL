#!/bin/bash
for ((i=66;i<=69;i++)) do
    if [ ! -d /sys/class/gpio/gpio$i ]; then
        echo $i > /sys/class/gpio/export
    fi
    if [ ! $(cat /sys/class/gpio/gpio$i/direction) = "in" ]; then
        echo in > /sys/class/gpio/gpio$i/direction
    fi
done
for ((i=70;i<=80;i++)) do
    if [ ! -d /sys/class/gpio/gpio$i ]; then
        echo $i > /sys/class/gpio/export
    fi
    if [ ! $(cat /sys/class/gpio/gpio$i/direction) = "out" ]; then
        echo out > /sys/class/gpio/gpio$i/direction
    fi
done
