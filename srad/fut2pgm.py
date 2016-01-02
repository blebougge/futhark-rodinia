#!/usr/bin/env python
#
# Simple tool for converting a Futhark data file to a PGM file.  The
# produced PGM will always be of type P2 (greyscale) and with a bit
# depth of 255.
#
# Reads from stdin and prints to stdout.

import ast
import sys

if __name__ == '__main__':
    input = sys.stdin.read()
    data = ast.literal_eval(input)
    rows = len(data)
    cols = len(data[0])
    print('P2')
    print(cols, rows)
    print(255)
    for row in data:
        for pixel in row:
            sys.stdout.write(str(pixel) + ' ')
        sys.stdout.write('\n')
