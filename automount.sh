#!/bin/bash
current=`fdisk -l`
prev=$current
while [ 1 ]
do
    current=$(fdisk -l)
    if [ "$current" != "$prev" ]
    then
        data=$(blkid | sed -e '$!d')
        arr=($data)
        mount_dir=${arr::-1}
        echo $mount_dir
        file_sys=$(echo ${arr[3]} | cut -c 7-10)
        echo $file_sys
        if [ ! -d /mnt/usbdrive ]; then
            mkdir /mnt/usbdrive
            mount -t $file_sys $mount_dir /mnt/usbdrive
            echo "Pendrive Inserted"
            touch error_log.txt
            mv error_log.txt /mnt/usbdrive/
            echo "Log file transferred"
            echo "Unmounting"
            umount $mount_dir
            echo "Unmounting succesful"
        else
            rm -r /mnt/usbdrive
            echo "Pendrive removed"
        fi
        exit 0
    fi
    prev=$current
    sleep 5
done
