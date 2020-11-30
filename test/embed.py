""" Embed RISC-V instructions into a valid C source code
    The C source code can be compiled and executed in the docker container
"""
import sys

from common import instructions

res = []
res.append('#include <stdio.h>\n')
res.append('int main() {\n')

# PC
res.append('int pc = -4;\n')

# Each register is a variable in C
res.append('int x0=0')
res += [',x{}=0'.format(i) for i in range(1, 32)]
res.append(';\n')

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
        imm = rs1[:-1]

    res.append('printf("PC = %d\\n", (pc+=4));\n')
    res.append('printf("Registers\\n");\n')
    res.append('printf("x0     = %10d, x8(s0)  = %10d, x16(a6) = %10d, x24(s8)  = %10d\\n", x0, x8 , x16, x24);\n')
    res.append('printf("x1(ra) = %10d, x9(s1)  = %10d, x17(a7) = %10d, x25(s9)  = %10d\\n", x1, x9 , x17, x25);\n')
    res.append('printf("x2(sp) = %10d, x10(a0) = %10d, x18(s2) = %10d, x26(s10) = %10d\\n", x2, x10, x18, x26);\n')
    res.append('printf("x3(gp) = %10d, x11(a1) = %10d, x19(s3) = %10d, x27(s11) = %10d\\n", x3, x11, x19, x27);\n')
    res.append('printf("x4(tp) = %10d, x12(a2) = %10d, x20(s4) = %10d, x28(t3)  = %10d\\n", x4, x12, x20, x28);\n')
    res.append('printf("x5(t0) = %10d, x13(a3) = %10d, x21(s5) = %10d, x29(t4)  = %10d\\n", x5, x13, x21, x29);\n')
    res.append('printf("x6(t1) = %10d, x14(a4) = %10d, x22(s6) = %10d, x30(t5)  = %10d\\n", x6, x14, x22, x30);\n')
    res.append('printf("x7(t2) = %10d, x15(a5) = %10d, x23(s7) = %10d, x31(t6)  = %10d\\n", x7, x15, x23, x31);\n')
    res.append('printf("\\n\\n");\n')
    res.append('\n')

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
