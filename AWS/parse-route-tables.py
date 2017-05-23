#!/usr/bin/env python
import json
import sys

data = json.load(sys.stdin)
for rt in data['RouteTables']:
    skip = False
    if 'Associations' in rt:
        for ass in rt['Associations']:
            skip = ass['Main']
    if not skip:
        print(rt["RouteTableId"])
