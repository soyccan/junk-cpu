#!python3
""" Generate random instructions """
import random
import sys

from common import instructions

num_inst = 30
res = ['addi x1, x0, 122\n',
       'addi x2, x0, -222\n',
       'addi x3, x0, 333\n',
       'addi x4, x0, 44\n',
       'sw x4, 4(x0)\n',
       'addi x4, x4, 66\n',
       'sw x4, 8(x0)\n',
       'sub x4, x1, x4\n',
       'sw x4, 0(x4)\n']
pc = 4 * len(res)
dq = [-1, -1]
for i in range(num_inst):
    inst_name = random.sample(instructions.keys(), 1)[0]
    inst = instructions[inst_name]
    rs1 = random.randint(0, 2)
    if rs1 == dq[0] or rs1 == dq[1]: 
        rs1 = 0
    rs2 = random.randint(1, 2)
    if rs2 == dq[0] or rs2 == dq[1]: 
        rs2 = 0
    rd = random.randint(1, 2)
    imm = random.randint(-(1 << 11), (1 << 11)-1)
    addr = random.randint(0, 2) * 4
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
