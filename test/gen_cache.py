#!python3
""" Generate random instructions for testing cache """
import random
import sys

from common import instructions

num_inst = 30
res = []
pc = 4 * len(res)
dq = [-1, -1]
for i in range(num_inst):
    inst_name = random.sample(['lw', 'sw'], 1)[0]
    inst = instructions[inst_name]
    rs1 = 0
    if rs1 == dq[0] or rs1 == dq[1]: 
        rs1 = 0
    rs2 = random.randint(24, 31)
    if rs2 == dq[0] or rs2 == dq[1]: 
        rs2 = 0
    rd = random.randint(2, 4)
    imm = random.randint(-(1 << 11), (1 << 11)-1)
    addr = random.sample([random.randint(0, 0x60),
                          random.randint(0x200, 0x260),
                          random.randint(0x400, 0x460)], 1)[0] & 0xffc
    shft_amt = random.randint(0, 31)
    upper_val = random.randint(0, (1 << 20) - 1)
    branch_target = random.randint(0, (num_inst-1) * 4) // 4 * 4 # .text relative
    if inst['type'] == 'r':
        res.append('{} x{}, x{}, x{}\n'.format(inst_name,
                                               rd,
                                               rs1,
                                               rs2))
        dq.pop(0)
        dq.append(rd)

    elif inst['type'] == 'i':
        if inst_name in ('slli', 'srli', 'srai'):
            res.append('{} x{}, x{}, {}\n'.format(inst_name,
                                                  rd,
                                                  rs1,
                                                  shft_amt))
        elif inst_name in ('lb', 'lh', 'lw', 'ld'):
            res.append('{} x{}, {}(x{})\n'.format(inst_name,
                                                 rd,
                                                 addr,
                                                 rs1))
        else:
            res.append('{} x{}, x{}, {}\n'.format(inst_name,
                                                  rd,
                                                  rs1,
                                                  imm))
        dq.pop(0)
        dq.append(rd)
    elif inst['type'] == 'u':
        res.append('{} x{}, {}\n'.format(inst_name,
                                         rd,
                                         upper_val))
        dq.pop(0)
        dq.append(rd)
    elif inst['type'] == 's':
        res.append('{} x{}, {}(x{})\n'.format(inst_name,
                                              rs2,
                                              addr,
                                              rs1))
    elif inst['type'] == 'b':
        res.append('{} x{}, x{}, .text+{} # {}\n'.format(inst_name,
                                                         rs1,
                                                         rs2,
                                                         branch_target,
                                                         branch_target - pc))
        dq.pop(0)
        dq.append(-1)
    else:
        raise Exception('Unsupported instruction!')
    pc += 4

sys.stdout.writelines(res)

