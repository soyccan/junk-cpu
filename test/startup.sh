#!/bin/sh
# spike --rbb-port=9824 -m0x10000000:0x20000 a.out &
# openocd -f spike.cfg &
set -ex
cd tmp
riscv64-unknown-elf-gcc -g -Og -c a.c
riscv64-unknown-elf-gcc -g -Og -T ../spike.lds -nostartfiles a.o
spike pk a.out | head -n -10 | tail -n +2 | tee a.log
bash
