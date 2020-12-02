#!python3
""" Embed RISC-V instructions into a valid C source code
    The C source code can be compiled and executed in the docker container
"""
import sys

from common import instructions

res = []
res.append('#include <stdio.h>\n')
res.append('int main() {\n')

# Global variables 
res.append('int pc = -4;\n')
res.append('int counter = -1;\n')
res.append('int Start = 1;\n')
res.append('int stall = 1;\n')
res.append('int flush = 1;\n')

# Each register is a variable in C
res.append('int x0=0')
res += [',x{}=0'.format(i) for i in range(1, 32)]
res.append(';\n')

# Memory
res.append('int memory[8] = {0};\n')

for ln in sys.stdin.readlines():
    inst_name, rd, rs1, *rs2 = ln.strip('\n').split(' ')
    inst = instructions[inst_name]

    if inst['type'] == 'r':
        rd = rd[:-1]
        rs1 = rs1[:-1]
        rs2 = rs2[0]

    elif inst['type'] == 'i':
        rd = rd[:-1]
        rs1 = rs1[:-1]
        imm = rs2[0]

    elif inst['type'] == 'u':
        rd = rd[:-1]
        imm = rs1

    res.append('printf("cycle = %d, Start = %0d, Stall = %0d, Flush = %0d\\nPC = %d\\n", (++counter), Start, stall, flush, (pc+=4));\n')

    # print Registers
    res.append('printf("Registers\\n");\n')
    res.append('printf("x0 = %10d, x8  = %10d, x16 = %10d, x24 = %10d\\n", x0, x8 , x16, x24);\n')
    res.append('printf("x1 = %10d, x9  = %10d, x17 = %10d, x25 = %10d\\n", x1, x9 , x17, x25);\n')
    res.append('printf("x2 = %10d, x10 = %10d, x18 = %10d, x26 = %10d\\n", x2, x10, x18, x26);\n')
    res.append('printf("x3 = %10d, x11 = %10d, x19 = %10d, x27 = %10d\\n", x3, x11, x19, x27);\n')
    res.append('printf("x4 = %10d, x12 = %10d, x20 = %10d, x28 = %10d\\n", x4, x12, x20, x28);\n')
    res.append('printf("x5 = %10d, x13 = %10d, x21 = %10d, x29 = %10d\\n", x5, x13, x21, x29);\n')
    res.append('printf("x6 = %10d, x14 = %10d, x22 = %10d, x30 = %10d\\n", x6, x14, x22, x30);\n')
    res.append('printf("x7 = %10d, x15 = %10d, x23 = %10d, x31 = %10d\\n", x7, x15, x23, x31);\n')

    # print Data Memory
    res.append('printf("Data Memory: 0x00 = %10d\\n", memory[0]);\n')
    res.append('printf("Data Memory: 0x04 = %10d\\n", memory[1]);\n')
    res.append('printf("Data Memory: 0x08 = %10d\\n", memory[2]);\n')
    res.append('printf("Data Memory: 0x0C = %10d\\n", memory[3]);\n')
    res.append('printf("Data Memory: 0x10 = %10d\\n", memory[4]);\n')
    res.append('printf("Data Memory: 0x14 = %10d\\n", memory[5]);\n')
    res.append('printf("Data Memory: 0x18 = %10d\\n", memory[6]);\n')
    res.append('printf("Data Memory: 0x1C = %10d\\n", memory[7]);\n')

    res.append('printf("\\n\\n");\n')

    # Evaluate instructions
    res.append('asm volatile(\n')
    if inst['type'] == 'r':
        res.append('"{} %[_{}], %[_{}], %[_{}]\\n\\t"\n'.format(
            inst_name, rd, rs1, rs2))
    elif inst['type'] == 'i':
        res.append('"{} %[_{}], %[_{}], {}\\n\\t"\n'.format(
            inst_name, rd, rs1, imm))
    elif inst['type'] == 'u':
        res.append('"{} %[_{}], {}\\n\\t"\n'.format(inst_name, rd, imm))
    else:
        raise ValueError()

    if inst['type'] == 'r':
        if rd == rs1 == rs2:
            res.append(': [_{}] "+r" ({})\n'.format(rd, rd))
        elif rd == rs1:
            res.append(': [_{}] "+r" ({})\n'.format(rd, rd))
            res.append(': [_{}] "r" ({})\n'.format(rs2, rs2))
        elif rd == rs2:
            res.append(': [_{}] "+r" ({})\n'.format(rd, rd))
            res.append(': [_{}] "r" ({})\n'.format(rs1, rs1))
        elif rs1 == rs2:
            res.append(': [_{}] "=r" ({})\n'.format(rd, rd))
            res.append(': [_{}] "r" ({})\n'.format(rs1, rs1))
        else:
            res.append(': [_{}] "=r" ({})\n'.format(rd, rd))
            res.append(': [_{}] "r" ({}), [_{}] "r" ({})\n'.format(rs1, rs1, rs2, rs2))
    elif inst['type'] == 'i':
        if rd == rs1:
            res.append(': [_{}] "+r" ({})\n'.format(rd, rd))
        else:
            res.append(': [_{}] "=r" ({})\n'.format(rd, rd))
            res.append(': [_{}] "r" ({})\n'.format(rs1, rs1))
    elif inst['type'] == 'u':
        res.append(': [_{}] "=r" ({})\n'.format(rd, rd))
    else:
        raise ValueError()
    res.append(');\n')

res.append('}')

sys.stdout.write(''.join(res))
