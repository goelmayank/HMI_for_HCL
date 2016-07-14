#!/bin/bash
mv rtc_ds1307 /usr/share/
mv rtc-ds1307.service /lib/systemd/system/
systemctl enable rtc-ds1307.service
