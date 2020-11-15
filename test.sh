#!/bin/sh
python test_gen.py | tee instruction.in
python test_eval.py < instruction.in | tee output_py.txt
python test_asm.py < instruction.in | tee instruction.txt
iverilog CPU.v Control.v ALU.v ALU_Control.v Sign_Extend.v PC.v \
         Instruction_Memory.v Registers.v
./a.out
