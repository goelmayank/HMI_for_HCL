#!/bin/bash
sec=$(cat pc_time.txt | cut -c 18-19)
min=$(cat pc_time.txt | cut -c 15-16)
hrs=$(cat pc_time.txt | cut -c 12-13)
date=$(cat pc_time.txt |cut -c 9-10)
month=$(cat pc_time.txt | cut -c 5-7)
year=$(cat pc_time.txt | cut -c 21-24)
month_names=("Jan", "Feb", "Mar", "Apr", "May" "Jun" "Jul" "Aug" "Sep" "Oct" "Nov" "Dec")
i=0;
while [ ! $month = ${month_names[i]} ]; do
    ((i++))
done
month=`expr $i + 1`
echo $month
date -s "$year-$month-$date $hrs:$min:$sec"
i2cset -y 2 0x68 00 $sec
i2cset -y 2 0x68 01 $min
i2cset -y 2 0x68 02 $hrs
i2cset -y 2 0x68 04 $date
i2cset -y 2 0x68 05 $month
i2cset -y 2 0x68 06 $year