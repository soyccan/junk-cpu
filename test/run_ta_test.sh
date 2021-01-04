#!/bin/bash
iverilog -I../src -Wall -o cpu.out ../src/*.v *.v
unzip -jo ../ta/CA2020_project2_testdata.zip
for input in instruction_*.txt; do
    cp -v "$input" instruction.txt
    ./cpu.out
    cp -v output.txt "eval_output_${input#instruction_}"
    cp -v cache.txt "eval_cache_${input#instruction_}"
done

