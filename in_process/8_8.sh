#!/bin/bash
declare -A matrix
rm ./a.txt
num_rows=8
num_columns=8
num_queens=8
count=0
b=0
f1="%$((${#num_rows}+1))s"
f2=" %9s"

function fill_and_block {
    echo $1
    echo $2
    matrix[$1,$2]="QUEEN"
    ((count++))
    for ((k=0;k<num_rows;k++)) do
        matrix[$1,$k]=$RANDOM
        matrix[$k,$2]=$RANDOM
        for ((l=0;l<num_columns;l++)) do
            if [ $(( 1-2 )) -eq $(( k-l )) ]
            then
                matrix[$i,$j]=$RANDOM
            fi
            if [ $(( 1+2 )) -eq $(( k+l )) ]
            then
                matrix[$i,$j]=$RANDOM
            fi
        done
    done
}

while [ $count -ne $num_queens ] 
do
    i=0
    if [ $b -eq 64 ]
    then
        ((step++))
    fi
    echo  "possibility no $((b+1)):" >> ./a.txt
	for ((k=0;k<num_rows;k++)) do
        for ((l=0;l<num_columns;l++)) do
            if [ $((i++)) -eq $b ]
            then
	            fill_and_block $k $l
	        fi
        done
    done
    ((b++))
    for ((i=0;i<num_rows;i++)) do
	    for ((j=0;j<num_columns;j++)) do
	    	if [ ! -z "${matrix[$i,$j]}" ]
	        then
	            fill_and_block $k $l
	        fi
	        printf "$f2" ${matrix[$i,$j]} >> ./a.txt
	    done
	    echo >> ./a.txt
	done
done
echo "output saved in file a.txt"
return
