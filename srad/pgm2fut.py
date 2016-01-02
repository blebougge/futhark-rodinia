#!/usr/bin/env python
#
# Simple tool for converting a PGM image to a Futhark data file.  This
# has only been tested on a very few PGM, and comments are not
# supported.
#
# Reads from stdin and prints to stdout.

import sys

if __name__ == '__main__':
    input = sys.stdin.read()
    words = input.split()
    cols = int(words[1])
    rows = int(words[2])
    data = map(int, words[4:])

    print(map(list, zip(*[iter(data)]*cols)))
