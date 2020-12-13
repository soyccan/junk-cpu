#!/bin/sh
# Run this file in a temporary directory
set -ex

unzip -jo ../ta/CA2020_project1.zip

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
    docker-compose up  # assembles a.s into instructions.txt also

    # Run by JunkCPU
    ./cpu.out >/dev/null

    if ! python ../test/diff.py output.txt a.log >/dev/null; then
        echo !!!!!!!!!!!!!!!!!
        echo Output Different!
        echo !!!!!!!!!!!!!!!!!
        break
    fi
done
