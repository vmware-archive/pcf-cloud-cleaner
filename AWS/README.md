## The Cleaner

This is a AWS version of "The Cleaner".  It runs through and deletes everything that would typically be setup by a PCF installation.

** THIS SCRIPT IS VERY DESTRUCTIVE BE CAREFUL WITH IT **

It will run through all regions and remove the following:

- EC2 instances
- EC2 volumes
- RDS instances
- ELBs
- public IP addresses
- S3 buckets
- security groups
- key pairs
- subnets
- network ACLs
- route tables
- internet gateways
- VPCs
- CloudFormation stacks

You probably do not want to run this unless you have total control of the account (i.e. don't run when multiple people are sharing an account).

## Purpose

The purpose for this is cleaning up lab environments.  It's meant to be run by Concourse, but could be run manually as well.

## Usage

To run it manually with Docker:

```
docker run -it -v $(pwd):/the-cleaner -w /the-cleaner ubuntu /bin/bash
./setup.sh
export AWS_ACCESS_KEY=<your-key>
export AWS_SECRET_KEY=<your-secret>
./run.sh
```
