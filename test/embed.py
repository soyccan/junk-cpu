#!python3
""" Embed RISC-V instructions into a valid C source code
    The C source code can be compiled and executed in the docker container
"""
import sys
import re

from common import instructions


info = []

info.append('printf("cycle = %d, Start = %0d, Stall = %0d, Flush = %0d\\nPC = %d\\n", (++counter), Start, stall, flush, (pc+=4));\n')

# print Registers
info.append('printf("Registers\\n");\n')
info.append('printf("x0 = %10d, x8  = %10d, x16 = %10d, x24 = %10d\\n", x0, x8 , x16, x24);\n')
info.append('printf("x1 = %10d, x9  = %10d, x17 = %10d, x25 = %10d\\n", x1, x9 , x17, x25);\n')
info.append('printf("x2 = %10d, x10 = %10d, x18 = %10d, x26 = %10d\\n", x2, x10, x18, x26);\n')
info.append('printf("x3 = %10d, x11 = %10d, x19 = %10d, x27 = %10d\\n", x3, x11, x19, x27);\n')
info.append('printf("x4 = %10d, x12 = %10d, x20 = %10d, x28 = %10d\\n", x4, x12, x20, x28);\n')
info.append('printf("x5 = %10d, x13 = %10d, x21 = %10d, x29 = %10d\\n", x5, x13, x21, x29);\n')
info.append('printf("x6 = %10d, x14 = %10d, x22 = %10d, x30 = %10d\\n", x6, x14, x22, x30);\n')
info.append('printf("x7 = %10d, x15 = %10d, x23 = %10d, x31 = %10d\\n", x7, x15, x23, x31);\n')

# print Data Memory
info.append('printf("Data Memory: 0x00 = %10d\\n", memory[0]);\n')
info.append('printf("Data Memory: 0x04 = %10d\\n", memory[1]);\n')
info.append('printf("Data Memory: 0x08 = %10d\\n", memory[2]);\n')
info.append('printf("Data Memory: 0x0C = %10d\\n", memory[3]);\n')
info.append('printf("Data Memory: 0x10 = %10d\\n", memory[4]);\n')
info.append('printf("Data Memory: 0x14 = %10d\\n", memory[5]);\n')
info.append('printf("Data Memory: 0x18 = %10d\\n", memory[6]);\n')
info.append('printf("Data Memory: 0x1C = %10d\\n", memory[7]);\n')

info.append('printf("\\n\\n");\n')


res = []
res.append('#include <stdio.h>\n')
res.append('#define min(x, y) ( (x) < (y) ? (x) : (y) )\n')
res.append('#define memory_addr(x) ((unsigned long)memory + min('
           '(x) & 0xfffffffc, sizeof(memory) - sizeof(int)))\n')
res.append('int main() {\n')

# Global variables 
res.append('int pc = -4;\n')
res.append('int counter = -1;\n')
res.append('int Start = 1;\n')
res.append('int stall = 0;\n')
res.append('int flush = 0;\n')

# Each register is a variable in C
res.append('int x0=0')
res += [',x{}=0'.format(i) for i in range(1, 32)]
res.append(';\n')

# Memory
res.append('int memory[4096] = {5};\n')

# First few cycles in pipelined CPU don't show changes
res += info * 4
pc = 0
for ln in sys.stdin.readlines():
    inst_name, *ops = ln.strip(')\n').replace(',', ' ').replace('(', ' ').split()
    inst = instructions[inst_name]

    if inst['type'] == 'r':
        rd = ops[0]
        rs1 = ops[1]
        rs2 = ops[2]

    elif inst['type'] == 'i':
        if inst_name in ('lb', 'lh', 'lw', 'ld'):
            rd = ops[0]
            imm = ops[1]
            rs1 = ops[2]
        else:
            rd = ops[0]
            rs1 = ops[1]
            imm = ops[2]

    elif inst['type'] == 'u':
        rd = ops[0]
        imm = ops[1]

    elif inst['type'] == 's':
        rs2 = ops[0]
        imm = ops[1]
        rs1 = ops[2]

    elif inst['type'] == 'b':
        rs1 = ops[0]
        rs2 = ops[1]
        branch_target = ops[2]

    # Evaluate instructions
    res.append('x0=0;\n') # x0 is always zero
    if inst['type'] == 'r':
        res += info
        res.append('asm volatile(\n')
        res.append('"L{}:\\n\\t"\n'.format(pc))
        res.append('"{} %[_rd], %[_rs1], %[_rs2]\\n\\t"\n'.format(inst_name))
        res.append(': [_rd] "=r" ({})\n'.format(rd))
        res.append(': [_rs1] "r" ({}), [_rs2] "r" ({})\n'.format(rs1, rs2))
        res.append(');\n')
    elif inst['type'] == 'i':
        if inst_name in ('lb', 'lh', 'lw', 'ld'):
            res += info
            res.append('asm volatile(\n')
            res.append('"L{}:\\n\\t"\n'.format(pc))
            res.append('"{} %[_rd], {}(%[_rs1])\\n\\t"\n'.format(inst_name, imm))
            res.append(': [_rd] "=r" ({})\n'.format(rd))
            res.append(': [_rs1] "r" (memory_addr({}))\n'.format(rs1)) # aligned
            res.append(');\n')
        else:
            res += info
            res.append('asm volatile(\n')
            res.append('"L{}:\\n\\t"\n'.format(pc))
            res.append('"{} %[_rd], %[_rs1], {}\\n\\t"\n'.format(inst_name, imm))
            res.append(': [_rd] "=r" ({})\n'.format(rd))
            res.append(': [_rs1] "r" ({})\n'.format(rs1))
            res.append(');\n')
    elif inst['type'] == 'u':
        res += info
        res.append('asm volatile(\n')
        res.append('"L{}:\\n\\t"\n'.format(pc))
        res.append('"{} %[_rd], {}\\n\\t"\n'.format(inst_name, imm))
        res.append(': [_rd] "=r" ({})\n'.format(rd))
        res.append(');\n')
    elif inst['type'] == 's':
        res.append('asm volatile(\n')
        res.append('"L{}:\\n\\t"\n'.format(pc))
        res.append('"{} %[_rs2], {}(%[_rs1])\\n\\t"\n'.format(inst_name, imm))
        res.append(':\n')
        res.append(': [_rs1] "r" (memory_addr({})), [_rs2] "r" ({})\n'.format(rs1, rs2)) # aligned
        res.append(');\n')

        # Store completes at 4-th stage, so should print state later
        res += info

    elif inst['type'] == 'b':
        res += info
        res.append('asm volatile(\n')
        res.append('"L{}:\\n\\t"\n'.format(pc))
        res.append('"{} %[_rs1], %[_rs2], L{}\\n\\t"\n'.format(inst_name, branch_target))
        res.append(':\n')
        res.append(': [_rs1] "r" ({}), [_rs2] "r" ({})\n'.format(rs1, rs2))
        res.append(');\n')
    else:
        raise ValueError()
    pc += 4

res += info
res.append('}')

sys.stdout.write(''.join(res))
