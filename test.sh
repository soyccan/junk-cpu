#!/bin/sh

python test_gen.py | tee instruction.in
python test_eval.py < instruction.in | tee output_py.txt
python test_asm.py < instruction.in | tee instruction.txt
