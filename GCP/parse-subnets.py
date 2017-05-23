#!/usr/bin/env python
from __future__ import print_function
import json
import sys

data = json.load(sys.stdin)
for subnet in data:
    if subnet['name'] != 'default':
        print("{} --region={}"
              .format(subnet['name'], subnet['region']), end='\0')
