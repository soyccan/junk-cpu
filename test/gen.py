#!python3
""" Generate random instructions """
import random
import sys

from common import instructions

num_inst = 30
res = []
pc = 0
dq = [-1, -1]
for i in range(num_inst):
    inst_name = random.sample(instructions.keys(), 1)[0]
    inst = instructions[inst_name]
    rs1 = random.randint(1, 3)
    if rs1 == dq[0] or rs1 == dq[1]: 
        rs1 = 0
    rs2 = random.randint(1, 3)
    if rs2 == dq[0] or rs2 == dq[1]: 
        rs2 = 0
    rd = random.randint(0, 1)
    imm = random.randint(-(1 << 11), (1 << 11)-1)
    addr = random.randint(0, 2) * 4
    shft_amt = random.randint(0, 31)
    upper_val = random.randint(0, (1 << 20) - 1)
    branch_target = random.randint(-pc, (num_inst-1) * 4 - pc) // 2
    if inst['type'] == 'r':
        res.append('{} x{}, x{}, x{}\n'.format(inst_name,
                                               str(rd),
                                               str(rs1),
                                               str(rs2)))
        dq.pop(0)
        dq.append(rd)

    elif inst['type'] == 'i':
        if inst_name in ('slli', 'srli', 'srai'):
            res.append('{} x{}, x{}, {}\n'.format(inst_name,
                                                  str(rd),
                                                  str(rs1),
                                                  str(shft_amt)))
        elif inst_name in ('lb', 'lh', 'lw', 'ld'):
            res.append('{} x{}, {}(x{})\n'.format(inst_name,
                                                 str(rd),
                                                 str(addr),
                                                 str(rs1)))
        else:
            res.append('{} x{}, x{}, {}\n'.format(inst_name,
                                                  str(rd),
                                                  str(rs1),
                                                  str(imm)))
        dq.pop(0)
        dq.append(rd)
    elif inst['type'] == 'u':
        res.append('{} x{}, {}\n'.format(inst_name,
                                         str(rd),
                                         str(upper_val)))
        dq.pop(0)
        dq.append(rd)
    elif inst['type'] == 's':
        res.append('{} x{}, {}(x{})\n'.format(inst_name,
                                             str(rs2),
                                             str(addr),
                                             str(rs1)))
    elif inst['type'] == 'b':
        res.append('{} x{}, x{}, {}\n'.format(inst_name,
                                              str(rs1),
                                              str(rs2),
                                              str(branch_target)))
        dq.pop(0)
        dq.append(-1)
    else:
        raise Exception('Unsupported instruction!')
    pc += 4

sys.stdout.writelines(res)
