#!/bin/sh
set -ex 

ta='PC.v Instruction_Memory.v Registers.v testbench.v instruction.txt output_ref.txt'

rm -rf tmp
mkdir -p tmp
unzip -j b07902143_hw4.zip -d tmp

for f in $ta; do
    unzip -j CA2020_hw4.zip "CA2020_hw4/codes/$f" -d tmp
done

cd tmp
iverilog CPU.v Control.v ALU.v ALU_Control.v Sign_Extend.v PC.v \
         Instruction_Memory.v Registers.v testbench.v
./a.out
diff output.txt output_ref.txt

