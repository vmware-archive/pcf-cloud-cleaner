## The Cleaner

This is a Azure version of "The Cleaner".  It runs through and deletes everything that would typically be setup by a PCF installation.

** THIS SCRIPT IS VERY DESTRUCTIVE BE CAREFUL WITH IT **

It will run through all regions & zones and remove the following:

- VM instances
- availability sets
- network interfaces
- load balancers
- public IPs
- virtual networks
- network security groups
- storage accounts
- resource groups

You probably do not want to run this unless you have total control of the account (i.e. don't run when multiple people are sharing an account).

## Purpose

The purpose for this is cleaning up lab environments.  It's meant to be run by Concourse, but could be run manually as well.

## Usage

To run it manually with Docker:

```
docker run -it -v $(pwd):/the-cleaner -w /the-cleaner ubuntu /bin/bash
./setup.sh
export AZURE_USER=<your-service-user>
export AZURE_PASSWORD=<your-service-pass>
export AZURE_TENANT=<your-account-email>
./run.sh
```
