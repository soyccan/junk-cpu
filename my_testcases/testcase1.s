.global store_test
store_test:  
    addi x5, x0, 3
    sw   x5, 56(x10)
    sw   x5, 64(x10)
    addi x6, x0, 5
    sw   x6, 72(x10)
    sw   x6, 1016(x10)
    ret                  # eof

.global load_test
load_test:  
    addi x5, x0, 3
    sw   x5, 56(x10)
    sw   x5, 72(x10)
    lw   x6, 72(x10)
    lw   x7, 56(x10)
    addi x7, x6, 128
    sw   x6, 128(x10)
    sw   x7, 256(x10)
    ret                  # eof

.global add_sub_test
add_sub_test:  
    addi x5, x0, 3
    addi x6, x0, 4 #16
    add x7, x5, x6
    sub x28, x6, x5
    sw   x7, 64(x10)
    sw   x28, 80(x10)
    ret                  # eof

.global and_or_xor_test
and_or_xor_test:  
    addi x5, x0, 123
    addi x6, x0, 456
    and x7, x5, x6
    and x28, x6, x5
    and  x29, x5, x6
    and  x30, x6, x5
    xor x5, x7, x28
    xor x6, x29, x30
    sw   x5, 64(x10)
    sw   x6, 0(x10)
    sw   x7, 8(x10)
    sw   x28, 16(x10)
    sw   x29, 128(x10)
    sw   x30, 80(x10)
    ret                  # eof


.global andi_ori_xori_test
andi_ori_xori_test:  
    addi x5, x0, 123
    addi x6, x0, 456
    addi x7, x5, 789
    ori  x28, x5, 789
    addi x29, x5, 789
    sw   x7, 8(x10)
    sw   x28, 16(x10)
    sw   x29, 32(x10)
    ret                  # eof

.global slli_srli_test
slli_srli_test:
    addi x5, x0, 123
    addi x6, x0, 456
    srai x7, x5, 1
    srai x28, x5, 1
    sw   x7, 16(x10)
    sw   x28, 32(x10)
    ret                  # eof

.global bne_beq_test
bne_beq_test:
    addi x5, x0, 123
    addi x6, x0, 456
    addi x7, x0, 123
    beq x5, x6, 12#b1
    sw x6, 16(x10)
    sw x7, 24(x10)
b1:
    sw x5, 32(x10)
    beq x5, x6, 16#b2
    sw x6, 40(x10)
    sw x7, 48(x10)
    sw x5, 56(x10)
b2:
    sw x6, 64(x10)
    sw x5, 1016(x10)
    ret                  # eof

.global workload1
workload1:
    xor x15, x16, x16    # x15 = 0
    xor x16, x15, x15    # x16 = 0
    addi x14, x15, 1    # x14 = 1
    addi x11, x10, 4    # x11 = array address + 4
    addi x12, x15, 134
    addi x13, x15, 177
    addi x28, x15, 200  # x28 = 200
    add x5, x15, x16    # x5 = 0
L1:
    add x6, x5, x15    # x6 = 0
    addi x12, x12, 999
    add x7, x6, x15    # x7 = 0
    addi x13, x13, 888
    lw x29, 0(x10)
    lw x30, 16(x10)
    lw x31, 8(x10)
    addi x29, x29, 77
    addi x30, x29, 77
    addi x31, x29, 77
    add x29, x30, x31
    and x29, x29, x31
    and x30, x12, x30
    addi x30, x31, 1
    addi x31, x29, 111
    srai x31, x30, 1
    srai x29, x31, 4
    srai x30, x28, 5
    and x29, x30, x28
    xor x29, x13, x30
    add x30, x31, x29
    add x31, x7, x12
    xor x31, x29, x30
    xor x30, x30, x13
    and x29, x12, x29
    addi x16, x10, 5
    addi x10, x16, 2    # x10 += 7
    addi x16, x7, 1
    addi x7, x16, 1    # x7 += 2
    addi x11, x10, 1
    addi x10, x11, 1    # x10 += 2
    addi x16, x6, 1
    addi x6, x16, 1    # x6 += 2
    addi x16, x5, 1    
    addi x5, x16, 1    # x5 += 2
    sw x29, 0(x10)
    sw x30, 16(x10)
    sw x31, 8(x10)
    beq x6, x28, -152#L1    # x5 vs x28
    ret               # eof

.global workload2
workload2:
    xor x12, x11, x11    # x12 = 0
    addi x13, x12, 147  # x13 = 147
    srai x14, x13, 1    # x14 = 147 << 1
    and x12, x13, x14     # x12 = (147 << 1 + 147)
    addi x11, x10, 1000 # x11 = addr + 1000
    xor x13, x12, x12    # x13 = 0
J1:
    lw x5, 0(x10)
    addi x6, x5, 7
    beq x10, x11, 20 #J3
    beq x10, x10, 40 #J5
J2:
    addi x6, x10, 1
    addi x10, x6, 1
    beq x10, x10, 16#J4
J3:
    add x5, x12, x6
    sw x5, 0(x10)  
    beq x10, x10, -20#J2
J4:
    addi x13, x12, 123
    addi x12, x13, 456
    beq x10, x10, -48#J1
J5:
    ret              # eof


.global workload3
workload3:
    xor  x11, x10, x10
    xor  x5, x11, x11
    addi x6, x11, 1
    addi x29, x10, 1016
R1:
    add x7, x6, x5
    sw x7, 0(x10)
    xor x12, x10, x10
    addi x11, x10, 1
    add x10, x11, x12
    xor x11, x10, x10
    add x5, x6, x11
    add x6, x7, x11
    beq x29, x10, -32#R1
    ret              # eof
