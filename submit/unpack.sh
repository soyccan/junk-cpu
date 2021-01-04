#!/bin/sh
set -ex
prefix="teamImPastaBlackTea_project2"

dir="$(mktemp -d)"
unzip "${prefix}.zip" -d "$dir"
unzip -j ta/CA2020_project2_testdata.zip -d "$dir"
unzip -j ta/CA2020_project2.zip -d "$dir" \
      CA2020_project2/codes/PC.v \
      CA2020_project2/codes/Registers.v \
      CA2020_project2/codes/Instruction_Memory.v

cd "$dir/$prefix/codes"
iverilog *.v ../../*.v -o CPU.out
for i in $(seq 1 3); do
    cp ../../instruction_${i}.txt instruction.txt
    ./CPU.out
    sed -i'' 's/[0-9a-fx]*$//g' cache.txt
    sed -i'' 's/[0-9a-fx]*$//g' ../../cache_${i}.txt
    diff output.txt ../../output_${i}.txt
    diff cache.txt ../../cache_${i}.txt
done
