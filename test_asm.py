""" Assemble instructions in instruction.txt
    Write machine code (binary string) back to instruction.txt,
    keeping readable instructions as comment
"""
import sys
import subprocess
import logging as log


# Reference: https://github.com/Gallopsled/pwntools/blob/dev/pwnlib/asm.py
def _run(cmd, stdin = None):
    log.debug(subprocess.list2cmdline(cmd))
    try:
        proc = subprocess.Popen(
            cmd,
            stdin  = subprocess.PIPE,
            stdout = subprocess.PIPE,
            stderr = subprocess.PIPE,
            text = False
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


def main():
    #  log.basicConfig(level='DEBUG')

    asm_code = sys.stdin.readlines()

    _run(['riscv64-linux-gnu-as', '-o', '/tmp/a.out'], 
         ''.join(asm_code).encode())

    _run(['riscv64-linux-gnu-objcopy', 
          '-O', 'binary', '/tmp/a.out', '/tmp/a.out'])
    
    m_code = open('/tmp/a.out', 'br').read()
    m_code = [format_machine_code(m_code[i:i+4])
              for i in range(0, len(m_code), 4)]

    for i in range(len(asm_code)):
        sys.stdout.write(m_code[i] + ' //' + asm_code[i])
    

main()
