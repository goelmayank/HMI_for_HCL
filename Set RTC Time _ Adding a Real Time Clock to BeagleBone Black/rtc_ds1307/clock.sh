#!/bin/bash
echo "YY-MM-DD HR:MN:SC MD" > msg.txt
. text_display_msg.sh
. read_time.sh
while [ 1 ]; do
    echo "$(printf %02d $year)-$(printf %02d $month)-$(printf %02d $date) $(printf %02d $hrs):$(printf %02d $min):$(printf %02d $sec)   " > input.txt
    . text_display.sh
done