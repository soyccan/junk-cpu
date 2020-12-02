#!/bin/sh
# Run this file in a temporary directory
set -ex

unzip -jo ../ta/CA2020_project1.zip
unzip -jo ../ta/CA2020_project1_testdata.zip

# Overwrites files from zip
cp ../src/*.v .

iverilog -o cpu.out *.v

while true; do
    # Generate random instrucitons
    python ../test/gen.py >a.s

    # Run by RISC-V simulator
    python ../test/embed.py <a.s >a.c
    docker-compose up

    # Run by JunkCPU
    python ../test/asm.py <a.s >instruction.txt
    ./cpu.out

    if ! diff -w a.log output.txt >/dev/null; then
        echo !!!!!!!!!!!!!!!!!
        echo Output Different!
        echo !!!!!!!!!!!!!!!!!
        break
    fi
done
