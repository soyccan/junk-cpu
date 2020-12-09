#!python3
import sys

if len(sys.argv) < 3:
    print('Usage: {} longer_file shorter_file'.format(sys.argv[0]), file=sys.stderr)
    exit(1)

longer = open(sys.argv[1]).read().split('\n')
shorter = open(sys.argv[2]).read().split('\n')

for i in range(len(shorter)-1):
    if shorter[i].replace(' ', '') != longer[i].replace(' ', ''):
        print('Different! Line: {}'.format(i))
        exit(1)
        break

