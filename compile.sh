#!/bin/sh
iverilog CPU.v Control.v ALU.v ALU_Control.v Sign_Extension.v PC.v \
    Instruction_Memory.v Registers.v
