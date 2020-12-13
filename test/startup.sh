#!/bin/sh
set -ex

# spike --rbb-port=9824 -m0x10000000:0x20000 a.out &
# openocd -f spike.cfg &

cd tmp
python3 ../asm.py <a.s >instruction.txt
riscv32-unknown-elf-gcc -g -Og -c a.c
riscv32-unknown-elf-gcc -g -Og -T ../spike.lds -nostartfiles a.o
# riscv32-unknown-elf-g++ generate.cpp generate.s
spike /opt/riscv/riscv32-unknown-elf/bin/pk a.out | head -n -10 | tail -n +2 > a.log

bash
