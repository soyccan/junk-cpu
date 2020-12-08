#!/bin/sh
# Run this file in a temporary directory
set -ex

unzip -jo ../ta/CA2020_project1.zip
unzip -jo ../ta/CA2020_project1_testdata.zip

# Files in src/ has priority
for f in ../src/*; do
    rm -f "${f#../src/}"
done

iverilog -o cpu.out -I ../src *.v ../src/*.v

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
