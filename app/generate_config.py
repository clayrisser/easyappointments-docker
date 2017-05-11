#!/usr/bin/env python

import os
import re
import sys

def main(argv):
    lines = []
    with open(argv[len(argv) - 1]) as f:
        for line in f.readlines():
            for match in re.findall(r'\$\{.+\}', line):
                env_name = re.findall(r'(?<=\$\{).+(?=\})', match)[0]
                env = os.environ[env_name] if env_name in os.environ else ''
                if env_name == 'DEBUG_MODE':
                    env = os.environ['DEBUG'] if 'DEBUG' in os.environ else ''
                if env.lower() == 'true' or env.lower() == 'false':
                    env = env.lower()
                line = line.replace(match, env)
            lines.append(line)

    for line in lines:
        print(line)

main(sys.argv)
