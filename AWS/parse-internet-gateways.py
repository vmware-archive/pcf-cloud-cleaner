#!/usr/bin/env python
import json
import sys

data = json.load(sys.stdin)
for ig in data['InternetGateways']:
    if 'Attachments' in ig:
        for attachment in ig['Attachments']:
            print(
                "detach-internet-gateway --internet-gateway-id {} --vpc-id {}"
                .format(ig['InternetGatewayId'], attachment['VpcId']),
                end='\0')
    print("delete-internet-gateway --internet-gateway-id {}"
          .format(ig['InternetGatewayId']), end='\0')
