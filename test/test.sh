#!/bin/sh
# Run this file in a temporary directory
set -ex
unzip -jo ../CA2020_hw4.zip 
cp ../src/*.v .
while true; do
    python ../test/gen.py >a.s

    # Run in RISC-V simulator
    python ../test/embed.py <a.s >a.c
    docker-compose up

    # Run in iVerilog
    python ../test/asm.py <a.s >instruction.txt
    iverilog -o cpu.out *.v
    ./cpu.out

    if ! diff -w a.log output.txt >/dev/null; then
        echo !!!!!!!!!!!!!!!!!
        echo Output Different!
        echo !!!!!!!!!!!!!!!!!
        break
    fi
done
