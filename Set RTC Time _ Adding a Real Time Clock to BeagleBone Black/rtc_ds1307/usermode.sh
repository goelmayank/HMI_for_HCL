#!/bin/bash
function initialize {
	echo "YY-MM-DD HR:MN:SC MD" > msg.txt
	. text_display_msg.sh
	. read_time.sh
	t=($sec $min $hrs $date $month $year)
	mode=("SC" "MN" "HR" "DD" "MM" "YY")
	echo "$(printf %02d ${t[5]})-$(printf %02d ${t[4]})-$(printf %02d ${t[3]}) $(printf %02d ${t[2]}):$(printf %02d ${t[1]}):$(printf %02d ${t[0]}) ${mode[0]}" > input.txt
	. text_display.sh
	upperLimit=(59 59 23 30 12 99)
	lowerLimit=(00 00 00 01 01 15)
	monthLimit=(31 28 31 30 31 30 31 31 30 31 30 31)
	index=0
}
function check_userInput {
	flag=0
	up=`cat /sys/class/gpio/gpio67/value`
	down=`cat /sys/class/gpio/gpio69/value`
	modeUp=`cat /sys/class/gpio/gpio66/value`
	modeDown=`cat /sys/class/gpio/gpio68/value`
	if [ $up -eq 0 ]; then
		((t[index]++))
		flag=1
	elif [ $down -eq 0 ]; then
		((t[index]--))
		flag=1
	elif [ $modeUp -eq 0 ]; then
		((index++))
		flag=1
	elif [ $modeDown -eq 0 ]; then
		((index--))
		flag=1
	fi
}
function leapyear_check {
	if [ $((${t[5]}%400)) -eq 0 ]; then
		monthLimit[1]=29;
	else 
		monthLimit[1]=28;
	fi
	if [[ $((${t[5]}%4)) -eq 0 && $((${t[5]}%100)) -ne 0 ]]; then
		monthLimit[1]=29;
	else 
		monthLimit[1]=28;
	fi
}
function lowerLimit_check {
	c=$index
	while [ ${t[c]} -lt ${lowerLimit[c]} ]; do
		if [ $c -lt 5 ]; then
			t[c]=${upperLimit[c]}
			((t[c+1]--))
		else
			t[c]=15
		fi
		((c++))
	done
}
function upperLimit_check {
	month_index=`expr ${t[4]} - 1`
	c=$index
	if [ $c -eq 3 ]; then
		if [ ${t[3]} -gt ${monthLimit[month_index]} ]; then
			t[3]=${lowerLimit[3]}
			((t[4]++))
		fi
		c=4
	fi
	while [ ${t[c]} -gt ${upperLimit[c]} ]; do
		if [ $c -lt 5 ]; then
			t[c]=${lowerLimit[c]}
			((t[c+1]++))
		else
			t[c]=99
		fi
		((c++))
	done
	if [[ $c -eq 4 && ${t[3]} -gt ${monthLimit[month_index]} ]]; then
		t[3]=${monthLimit[month_index]}
	fi 
}
function print_change{
	if [ $flag ]; then
		echo "$(printf %02d ${t[5]})-$(printf %02d ${t[4]})-$(printf %02d ${t[3]}) $(printf %02d ${t[2]}):$(printf %02d ${t[1]}):$(printf %02d ${t[0]}) ${mode[index]}"
		echo "$(printf %02d ${t[5]})-$(printf %02d ${t[4]})-$(printf %02d ${t[3]}) $(printf %02d ${t[2]}):$(printf %02d ${t[1]}):$(printf %02d ${t[0]}) ${mode[index]}" > input.txt
		. text_display.sh
	fi
}
function update_time {
	date -s "${t[5]}-${t[4]}-${t[3]} ${t[2]}:${t[1]}:${t[0]}"
	i2cset -y 1 0x68 00 0x${t[0]}
	i2cset -y 1 0x68 01 0x${t[1]}
	i2cset -y 1 0x68 02 0x${t[2]}
	i2cset -y 1 0x68 04 0x${t[3]}
	i2cset -y 1 0x68 05 0x${t[4]}
	i2cset -y 1 0x68 06 0x${t[5]}
}

initialize
check_userInput
while [[ $index -ge 0 && $index -le 5 ]]; do
	leapyear_check
	lowerLimit_check
	upperLimit_check
	print_change
	check_userInput
done
update_time
echo "Out of User mode" > msg.txt
. text_display_msg.sh