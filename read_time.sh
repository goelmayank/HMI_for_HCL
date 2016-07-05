#!/bin/bash
sec=$(i2cget -y 1 0x68 00 | tail -c 3)
min=$(i2cget -y 1 0x68 01 | tail -c 3)
hrs=$(i2cget -y 1 0x68 02 | tail -c 3)
date=$(i2cget -y 1 0x68 04 | tail -c 3)
month=$(i2cget -y 1 0x68 05 | tail -c 3)
year=$(i2cget -y 1 0x68 06 | tail -c 3)
