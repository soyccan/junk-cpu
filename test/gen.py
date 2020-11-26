""" Generate random instructions """
import random
import sys

from common import instructions

num_inst = 29
res = []
for i in range(num_inst):
    inst_name = random.sample(instructions.keys(), 1)[0]
    inst = instructions[inst_name]
    rs1 = random.randint(0, 31)
    rs2 = random.randint(0, 31)
    rd = random.randint(0, 31)
    imm = random.randint(-(1 << 11), (1 << 11)-1)
    shft_amt = random.randint(0, 31)
    if inst['type'] == 'r':
        res.append('{} x{}, x{}, x{}\n'.format(inst_name,
                                               str(rd),
                                               str(rs1),
                                               str(rs2)))

    elif inst['type'] == 'i':
        if inst_name in ('srai',):
            res.append('{} x{}, x{}, {}\n'.format(inst_name,
                                                  str(rd),
                                                  str(rs1),
                                                  str(shft_amt)))
        else:
            res.append('{} x{}, x{}, {}\n'.format(inst_name,
                                                  str(rd),
                                                  str(rs1),
                                                  str(imm)))

    else:
        raise Exception('Unsupported instruction!')

sys.stdout.writelines(res)
