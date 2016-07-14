#!/bin/bash

FINAL_DIR=/home/debian/bin/HLC
DATA_DIR=/home/debian/bin/data
UART_PORT=`cat $DATA_DIR/uart_port.txt`
SYNC_DIR=/home/debian/bin/sync


MODE_GPIO=67		#SW1
UP_GPIO=69			#SW2
DN_GPIO=66			#SW3
SEL_GPIO=68			#SW4

GPIO_PATH=/sys/class/gpio/gpio
sync
TIME1=`date +%s`
TIME2=`date +%s`
SET_IDLE_TIME=300

function initialize {
	rm $DATA_DIR/current_time.txt
	
	sec=0
	min=0
	hrs=0
	dt=1
	month=7
	year=16

	t=($sec $min $hrs $dt $month $year)
	mode=("SC" "MN" "HR" "DD" "MM" "YY")
	echo "YY-MM-DD HR:MN:SC MD" > $DATA_DIR/ln1_lcd.txt
	echo "$(printf %02d $(( 10#${t[5]} )) )-$(printf %02d $(( 10#${t[4]} )) )-$(printf %02d $(( 10#${t[3]} )) ) $(printf %02d $(( 10#${t[2]} )) ):$(printf %02d $(( 10#${t[1]} )) ):$(printf %02d $(( 10#${t[0]} )) ) ${mode[0]}" > $DATA_DIR/ln2_lcd.txt
	$FINAL_DIR/send_data_to_lcd.o

	upperLimit=(59 59 23 30 12 99)
	lowerLimit=(00 00 00 01 01 15)
	monthLimit=(31 28 31 30 31 30 31 31 30 31 30 31)
	index=0
}
function check_userInput {
	flag=0
	
	up=`cat $GPIO_PATH$UP_GPIO/value`
	down=`cat $GPIO_PATH$DN_GPIO/value`
	modeUp=`cat $GPIO_PATH$MODE_GPIO/value`
	modeDown=`cat $GPIO_PATH$SEL_GPIO/value`
	echo "up=$up"
	echo "down=$down"
	echo "modeDown=$modeDown"
	echo "modeUp=$modeUp"
	if [ $up -eq 1 ]; then
		((t[index]++))
		TIME1=`date +%s`
		flag=1
	elif [ $down -eq 1 ]; then
		((t[index]--))
		TIME1=`date +%s` 
		flag=1
	elif [ $modeUp -eq 1 ]; then
		((index++))
		TIME1=`date +%s`
		flag=1
	elif [ $modeDown -eq 1 ]; then
		((index--))
		TIME1=`date +%s`
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
			if [ $c -eq 3 ]; then
				month_index=`expr ${t[4]} - 2`
				t[c]=${monthLimit[month_index]}
			else
				t[c]=${upperLimit[c]}
			fi
			((t[c+1]--))
		else
			t[c]=15
		fi
		((c++))
	done
}
function upperLimit_check {
	c=$index
	if [ $c -eq 3 ]; then
		month_index=`expr ${t[4]} - 1`
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
	echo $(( 10#${t[3]} ))
	echo ${monthLimit[month_index]}
	if [[ $c -eq 4 && $(( 10#${t[3]} )) -gt ${monthLimit[month_index]} ]]; then
		t[3]=${monthLimit[month_index]}
	fi 
}
function print_change {
	if [ $flag ]; then
		#echo "$(printf %02d ${t[5]})-$(printf %02d ${t[4]})-$(printf %02d ${t[3]}) $(printf %02d ${t[2]}):$(printf %02d ${t[1]}):$(printf %02d ${t[0]}) ${mode[index]}"
		echo "$(printf %02d $(( 10#${t[5]} )) )-$(printf %02d $(( 10#${t[4]} )) )-$(printf %02d $(( 10#${t[3]} )) ) $(printf %02d $(( 10#${t[2]} )) ):$(printf %02d $(( 10#${t[1]} )) ):$(printf %02d $(( 10#${t[0]} )) ) ${mode[$index]}" > $DATA_DIR/ln2_lcd.txt
		$FINAL_DIR/send_data_to_lcd.o
	fi
}

function update_time_in_RTC {
	date -s "${t[5]}-${t[4]}-${t[3]} ${t[2]}:${t[1]}:${t[0]}"
	i2cset -y 2 0x68 00 0x${t[0]}
	i2cset -y 2 0x68 01 0x${t[1]}
	i2cset -y 2 0x68 02 0x${t[2]}
	i2cset -y 2 0x68 04 0x${t[3]}
	i2cset -y 2 0x68 05 0x${t[4]}
	i2cset -y 2 0x68 06 0x${t[5]}
}

function update_time_from_PC {

	month_name=$(cat $DATA_DIR/current_time.txt | cut -c 5-7)
	month_name_array=('Jan' 'Feb' 'Mar' 'Apr' 'May' 'Jun' 'Jul' 'Aug' 'Sep' 'Oct' 'Nov' 'Dec')
	for((index2=1;! month_name = month_name_array[index2];index2++)); do
	done
	month=index2
	day=$(cat $DATA_DIR/current_time.txt | cut -c 9-10)
	hrs=$(cat $DATA_DIR/current_time.txt | cut -c 12-13)
	min=$(cat $DATA_DIR/current_time.txt | cut -c 15-16)
	sec=$(cat $DATA_DIR/current_time.txt | cut -c 18-19)
	yr=$(cat $DATA_DIR/current_time.txt | cut -c 23-24)
	t[0]=$sec
	t[1]=$min
	t[2]=$hrs
	t[3]=$date
	t[4]=$month
	t[5]=$yr

}

up=`cat $GPIO_PATH$UP_GPIO/value`
down=`cat $GPIO_PATH$DN_GPIO/value`

if [ $up -eq 1 -a $down -eq 1 ];
then
	#echo"12345678901234567890"
	echo "ENTERING IN" > $DATA_DIR/ln1_lcd.txt
	echo "DATE & TIME SETTING" > $DATA_DIR/ln2_lcd.txt
	$FINAL_DIR/send_data_to_lcd.o
	sleep 5
	
	TIME1=`date +%s`
	TIME2=`date +%s`
	
	initialize
	check_userInput
	echo $index
	while [[ $index -ge 0 && $index -le 5 && $IDLE_TIME -le $SET_IDLE_TIME && ! -f $DATA_DIR/current_time.txt ]]; do
		TIME2=`date +%s`
		IDLE_TIME=`expr $TIME2 - $TIME1`
		
		leapyear_check
		lowerLimit_check
		upperLimit_check
		print_change
		check_userInput
		echo $index
	done

	if [ $index -lt 0 -o $index -gt 5 -o -f $DATA_DIR/current_time.txt ];
	then
		if [ -f $DATA_DIR/current_time.txt ]; then
			update_time_from_PC
		fi
		update_time_in_RTC
		#echo"12345678901234567890"
		echo "DATE & TIME SET TO" > $DATA_DIR/ln1_lcd.txt
		echo "$(printf %02d $(( 10#${t[5]} )) )-$(printf %02d $(( 10#${t[4]} )) )-$(printf %02d $(( 10#${t[3]} )) ) $(printf %02d $(( 10#${t[2]} )) ):$(printf %02d $(( 10#${t[1]} )) ):$(printf %02d $(( 10#${t[0]} )) )" > $DATA_DIR/ln2_lcd.txt
		$FINAL_DIR/send_data_to_lcd.o
	else
		#echo"12345678901234567890"
		echo "CLOCK IS NOT UPDATED" > $DATA_DIR/ln1_lcd.txt
		echo " " > $DATA_DIR/ln2_lcd.txt
		$FINAL_DIR/send_data_to_lcd.o
	fi
	sleep 5
else
	sync
	#$FINAL_DIR/clr_lcd.o
fi