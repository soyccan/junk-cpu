#!/bin/sh
while true; do
    python test/gen.py >instruction.in
    python test/eval.py <instruction.in >output_py.txt
    python test/asm.py <instruction.in >instruction.txt
    iverilog src/CPU.v src/Control.v src/ALU.v src/ALU_Control.v \
        src/Sign_Extend.v src/PC.v \
        src/Instruction_Memory.v src/Registers.v src/testbench.v
    ./a.out
    if ! diff -w output.txt output_py.txt >/dev/null; then
        echo !!!!!!!!!!!!!!!!!
        echo Output Different!
        echo !!!!!!!!!!!!!!!!!
        break
    fi
done
