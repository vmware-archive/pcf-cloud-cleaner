## The Cleaner

This is a GCP version of "The Cleaner".  It runs through and deletes everything that would typically be setup by a PCF installation.

** THIS SCRIPT IS VERY DESTRUCTIVE BE CAREFUL WITH IT **

It will run through all regions & zones and remove the following:

- Compute instances
- Compute disks
- Compute images (custom)
- Forwarding rules
- target http proxies
- target https proxies
- target ssl proxies
- url maps
- backend services
- instance groups
- firewall rules
- network subnets
- networks
- public ip addresses
- target pools
- health checks
- http health checks
- https health checks

Does not currently delete:

 - Google SQL Databases
 - Google Storage Buckets

You probably do not want to run this unless you have total control of the account (i.e. don't run when multiple people are sharing an account).

## Purpose

The purpose for this is cleaning up lab environments.  It's meant to be run by Concourse, but could be run manually as well.

## Usage

To run it manually with Docker:

```
docker run -it -v $(pwd):/the-cleaner -w /the-cleaner ubuntu /bin/bash
./setup.sh
export GCP_ACCOUNT=<your-account-email>
export GCP_SERVICE_FILE=<relative-path-to-service-account-json-file>
export GCP_PROJECT=<your-project-name>
./run.sh
```
