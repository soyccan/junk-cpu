""" Evaluate instructions and output register state
"""
import sys
import struct

from test_common import instructions



class RegiserFile:
    def __init__(self, num_reg=32):
        self._registers = [0] * num_reg

    def __getitem__(self, index):
        return self.get(index)

    def __setitem__(self, index, value):
        self.set(index, value)

    def get(self, index):
        # signed 32-bit
        return struct.unpack('i', struct.pack('I', self._registers[index]))[0]

    def getu(self, index):
        # unsigned 32-bit
        return self._registers[index]

    def set(self, index, value):
        if value < 0:
            value = (-value - 1) ^ 0xffffffff
        assert value >= 0
        self._registers[index] = value & 0xffffffff


register = RegiserFile()
pc = 0

for ln in sys.stdin.readlines():

    print("PC = %d" % (pc,))
    print("Registers")
    print("x0     =%11d, x8(s0)  =%11d, x16(a6) =%11d, x24(s8)  =%11d" % (register[0], register[8] , register[16], register[24]))
    print("x1(ra) =%11d, x9(s1)  =%11d, x17(a7) =%11d, x25(s9)  =%11d" % (register[1], register[9] , register[17], register[25]))
    print("x2(sp) =%11d, x10(a0) =%11d, x18(s2) =%11d, x26(s10) =%11d" % (register[2], register[10], register[18], register[26]))
    print("x3(gp) =%11d, x11(a1) =%11d, x19(s3) =%11d, x27(s11) =%11d" % (register[3], register[11], register[19], register[27]))
    print("x4(tp) =%11d, x12(a2) =%11d, x20(s4) =%11d, x28(t3)  =%11d" % (register[4], register[12], register[20], register[28]))
    print("x5(t0) =%11d, x13(a3) =%11d, x21(s5) =%11d, x29(t4)  =%11d" % (register[5], register[13], register[21], register[29]))
    print("x6(t1) =%11d, x14(a4) =%11d, x22(s6) =%11d, x30(t5)  =%11d" % (register[6], register[14], register[22], register[30]))
    print("x7(t2) =%11d, x15(a5) =%11d, x23(s7) =%11d, x31(t6)  =%11d" % (register[7], register[15], register[23], register[31]))
    print()
    print()

    inst_name, rd, rs1, rs2 = ln.strip('\n').split(' ')
    inst = instructions[inst_name]

    if inst['type'] == 'r':
        rd = int(rd[1:-1])
        rs1 = int(rs1[1:-1])
        rs2 = int(rs2[1:])

    elif inst['type'] == 'i':
        rd = int(rd[1:-1])
        rs1 = int(rs1[1:-1])
        imm = int(rs2)

    if inst_name == 'and':
        register[rd] = register.getu(rs1) & register.getu(rs2)
    elif inst_name == 'xor':
        register[rd] = register.getu(rs1) ^ register.getu(rs2)
    elif inst_name == 'sll':
        # shift amount is lower 5 bits
        register[rd] = register.getu(rs1) << (register.getu(rs2) & 0x1f)
    elif inst_name == 'add':
        register[rd] = register.getu(rs1) + register.getu(rs2)
    elif inst_name == 'sub':
        register[rd] = register.getu(rs1) - register.getu(rs2)
    elif inst_name == 'mul':
        register[rd] = register.getu(rs1) * register.getu(rs2)
    elif inst_name == 'addi':
        register[rd] = register.getu(rs1) + imm
    elif inst_name == 'srai':
        register[rd] = register.getu(rs1) >> imm

    pc += 4


print("PC = %d" % (pc,))
print("Registers")
print("x0     =%11d, x8(s0)  =%11d, x16(a6) =%11d, x24(s8)  =%11d" % (register[0], register[8] , register[16], register[24]))
print("x1(ra) =%11d, x9(s1)  =%11d, x17(a7) =%11d, x25(s9)  =%11d" % (register[1], register[9] , register[17], register[25]))
print("x2(sp) =%11d, x10(a0) =%11d, x18(s2) =%11d, x26(s10) =%11d" % (register[2], register[10], register[18], register[26]))
print("x3(gp) =%11d, x11(a1) =%11d, x19(s3) =%11d, x27(s11) =%11d" % (register[3], register[11], register[19], register[27]))
print("x4(tp) =%11d, x12(a2) =%11d, x20(s4) =%11d, x28(t3)  =%11d" % (register[4], register[12], register[20], register[28]))
print("x5(t0) =%11d, x13(a3) =%11d, x21(s5) =%11d, x29(t4)  =%11d" % (register[5], register[13], register[21], register[29]))
print("x6(t1) =%11d, x14(a4) =%11d, x22(s6) =%11d, x30(t5)  =%11d" % (register[6], register[14], register[22], register[30]))
print("x7(t2) =%11d, x15(a5) =%11d, x23(s7) =%11d, x31(t6)  =%11d" % (register[7], register[15], register[23], register[31]))
print()
print()
