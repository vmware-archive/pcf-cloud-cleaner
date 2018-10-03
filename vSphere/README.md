## The Cleaner

This is a vSphere version of "The Cleaner".  It runs through and deletes everything that would typically be setup by a PCF installation.

** THIS SCRIPT IS VERY DESTRUCTIVE BE CAREFUL WITH IT **

It will run through all regions and remove the following:

- VMs under the assigned resource pool `RPXX`
- VMs in any folders that match the names `envXX`, `pcf_templates_envXX` and `pcf_vms_envXX`
- Folders with the same name patterns
- Any persistent disks under `pcf_disk_envXX`

Make sure to set ENV to the two digit environment number to clean up.  For single digit
environments add a leading zero.  Ex:  ENV=01 or ENV=23

## Purpose

The purpose for this is cleaning up lab environments.  It's meant to be run by Concourse, but could be run manually as well.

## Usage

Edit the ./env.sh 

```
export GOVC_URL='https://<vsphere-url>'
export GOVC_INSECURE=1
export GOVC_PERSIST_SESSION=1
export ENV=<two digit env number>
export GOVC_USERNAME="user"
export GOVC_PASSWORD='pass'
export GOVC_DATACENTER='Datacenter'
export GOVC_CLUSTER='Cluster'
export GOVC_DATASTORE='Datastore'
```

Using Docer to execute the clenanup

```
docker run -it -v $(pwd):/the-cleaner -w /the-cleaner ubuntu /bin/bash
./setup.sh
```

Execute the cleanup

```
./run.sh
```

## Concourse Usage

The `create-docker.sh` script & `Dockerfile` can be used to create a Docker image for use in a Concourse pipeline. If you're manually running these scripts, you can ignore these files.

If you'd like to integrate this with a Concourse pipeline, see the following instructions:

 <TODO: add example>
 
