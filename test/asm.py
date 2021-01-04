#!python3
""" Assemble instructions
    Output machine code in binary string,
    keeping readable instructions as comment
    Require riscv64 assembler
    Output Example:
        0100000_01101_10110_101_11000_0010011 //srai x24, x22, 13
"""
import sys
import subprocess
import logging as log
import os
import os.path
import glob
import re

from common import instructions


# Reference: https://github.com/Gallopsled/pwntools/blob/dev/pwnlib/asm.py
def _run(cmd, stdin=None):
    log.debug(subprocess.list2cmdline(cmd))
    try:
        proc = subprocess.Popen(
            cmd,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=False
        )
        stdout, stderr = proc.communicate(stdin)
        exitcode = proc.wait()
    except OSError as e:
        if e.errno == errno.ENOENT:
            log.exception('Could not run %r the program' % cmd[0])
        else:
            raise

    if (exitcode, stderr) != (0, ''):
        msg = 'There was an error running %s:\n' % repr(cmd)
        if exitcode != 0:
            msg += 'It had the exitcode %d.\n' % exitcode
        if stderr != '':
            msg += 'It had this on stdout:\n%s\n' % stderr
        log.error(msg)

    return stdout


def format_machine_code(m_code):
    assert isinstance(m_code, bytes)
    assert len(m_code) == 4

    res = list(bin(int.from_bytes(m_code, 'little'))[2:].rjust(32, '0'))
    res.insert(7, '_')
    res.insert(13, '_')
    res.insert(19, '_')
    res.insert(23, '_')
    res.insert(29, '_')
    return ''.join(res)


def format_asm_code(code):
    match = re.match(r'(.*?)([0-9]+)\((.*)\)', code)
    if match:
        code = '{}{}({})'.format(match[1], hex(int(match[2])), match[3])
    return code


def search_in_path(names):
    for name in names:
        for dir_ in os.environ['PATH'].split(':'):
            res = sorted(glob.glob(os.path.join(dir_, name)))
            if res:
                return res[0]
    return None


def main():
    #  log.basicConfig(level='DEBUG')

    asm_code = sys.stdin.readlines()

    assembler = search_in_path(
        ['riscv32-linux-gnu-as', 'riscv32-unknown-elf-as',
         'riscv64-linux-gnu-as', 'riscv64-unknown-elf-as'])
    objcopy = search_in_path(
        ['riscv32-linux-gnu-objcopy', 'riscv32-unknown-elf-objcopy',
         'riscv64-linux-gnu-objcopy', 'riscv64-unknown-elf-objcopy'])

    _run([assembler, '-o', '/tmp/a.out'], ''.join(asm_code).encode())

    _run([objcopy, '-O', 'binary', '/tmp/a.out', '/tmp/a.out'])

    m_code = open('/tmp/a.out', 'br').read()
    m_code = [format_machine_code(m_code[i:i+4])
              for i in range(0, len(m_code), 4)]

    for i in range(len(asm_code)):
        t = asm_code[i].split()
        if not t[0:] or t[0] not in instructions.keys():
            asm_code[i] = None
    asm_code = [format_asm_code(x) for x in asm_code if x]

    for i in range(len(asm_code)):
        sys.stdout.write(m_code[i] + ' // ' + asm_code[i] + '\n')


main()
