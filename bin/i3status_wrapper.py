#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Inspired by http://code.stapelberg.de/git/i3status/tree/contrib/wrapper.py

import sys
import json
import subprocess 

def print_nonbuffered(message):
    sys.stdout.write(message)
    sys.stdout.flush()

if __name__ == '__main__':
    print_nonbuffered(sys.stdin.readline())
    print_nonbuffered(sys.stdin.readline())
    while True:
        line, prefix = sys.stdin.readline(), ''
        if line.startswith(','):
            line, prefix = line[1:], ','
        j = json.loads(line)
        if '1' == subprocess.getoutput('xset q | grep LED')[65]:
            j.insert(len(j), {'full_text' : 'CAPS',
                              'separator_block_width': 40,
                              'color': '#FF0000'})
        print_nonbuffered(prefix+json.dumps(j))
