#!/bin/sh
set -ex
prefix="teamImPastaBlackTea_project1"

dir="$(mktemp -d)"
unzip -j ta/CA2020_project1.zip -d "$dir"
unzip -j ta/CA2020_project1_testdata.zip -d "$dir"
unzip -jo "${prefix}.zip" -d "$dir"

cd "$dir"
iverilog *.v
for i in $(seq 1 4); do
    cp instruction_${i}.txt instruction.txt
    ./a.out
    diff output.txt output_ref_${i}.txt
done
