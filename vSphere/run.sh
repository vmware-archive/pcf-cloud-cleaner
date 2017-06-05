#!/bin/bash
set -e

if [ "" == "$ENV" ]; then
    echo 'You must set environment variable ENV to the environment number to clean'
    exit -1
fi

if [ "" == "$GOVC_DATACENTER" ]; then
    echo 'You must set environment variable GOVC_DATACENTER to the Datacenter name'
    exit -1
fi

if [ "" == "$GOVC_CLUSTER" ]; then
    echo 'You must set environment variable GOVC_CLUSTER to the Cluster name'
    exit -1
fi

if [ "" == "$GOVC_DATASTORE" ]; then
    echo 'You must set environment variable GOVC_DATASTORE to the Datastore name'
    exit -1
fi

echo 'Deleting All VMs...'
./govc find -json -type=m "./host/Cluster/Resources/RP$ENV" | xargs -I{} ./govc vm.destroy "{}"
echo 'VMs gone'

echo 'Cleaning up folders...'
./govc ls "/${GOVC_DATACENTER}/vm/env$ENV/*" | xargs -I{} ./govc vm.destroy "{}"
./govc ls "/${GOVC_DATACENTER}/vm/pcf_templates_env$ENV/*" | xargs -I{} ./govc vm.destroy "{}"
./govc ls "/${GOVC_DATACENTER}/vm/pcf_vms_env$ENV/*" | xargs -I{} ./govc vm.destroy "{}"
echo 'Folders clean'

echo 'Deleting folders'
./govc object.destroy "/${GOVC_DATACENTER}/vm/env$ENV" || true
./govc object.destroy "/${GOVC_DATACENTER}/vm/pcf_vms_env$ENV" || true
./govc object.destroy "/${GOVC_DATACENTER}/vm/pcf_templates_env$ENV" || true
echo 'Folders gone'

echo 'Cleaning up persistent disks'
./govc datastore.rm -f "/pcf_disk_env$ENV"
echo 'Persistent disks gone'
echo 'Done!'
