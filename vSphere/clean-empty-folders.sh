#!/bin/bash
set -euo pipefail

# get list of VMs
echo "Loading list of all VMs"
./govc datastore.ls -R=false | sort > vm-list.txt
echo "Found [$(wc -l vm-list.txt)] VMs"

# look through for empty bosh deployed vm folders
echo "Finding bosh deployed VMs"
grep -e '^vm-' vm-list.txt > bosh-vms-list.txt
echo "Found [$(wc -l bosh-vms-list.txt)] VMs"

for VM in $(cat bosh-vms-list.txt); do
    echo "Checking folder [$VM]..."

    if [ "$VM" == "$(grep -e "^$VM$" skip-list.txt)" ]; then
        echo "Skipped [$VM] previously, skipping it again"
        continue
    fi

    JSON=$(./govc datastore.ls -json=true -R=false "/$VM")
    if [ "1" != "$(echo "$JSON" | jq '. | length')" ]; then
        echo "Unexpected JSON response [$(echo "$JSON" | jq .)]"
        exit -1;
    fi

    echo "Folder has [$(echo "$JSON" | jq '.[0].File | length')] files"

    if [ "2" == "$(echo "$JSON" | jq '.[0].File | length')" ]; then
        if [ "env.iso" == "$(echo "$JSON" | jq -r '.[0].File[0].Path')" ]; then
            if [ "env.json" == "$(echo "$JSON" | jq -r '.[0].File[1].Path')" ]; then
                # there are only two files in this folder & it's just env.iso and env.json
                #  -- this is a junk folder left behind by bosh, so we delete it --
                ./govc datastore.rm -f "/$VM" &
                continue
            fi
        fi
    fi

    if [ "0" == "$(echo "$JSON" | jq '.[0].File | length')" ]; then
        # empty folder, delete it
        ./govc datastore.rm -f "/$VM" &
        continue
    fi

    # look for folders without *.vmx files (that's the VM settings)
    #   can't just delete them, but represent potential unused VMs
    #
    # look for files name `vm-*`, these should match a VM with the same name
    #   if they don't, we can probably delete what's in the data store
    #
    # check the stemcells `sc-*`, there could be empty folders or 
    #   perhaps partial folders (not sure but worth investigating)
    #

    # fall through
    echo "File count or file names didn't match, skipping.."
    echo "Contents:"
    echo "$JSON" | jq '.'
    echo "$VM" >> skip-list.txt
done

# clean up
rm -f vm-list.txt bosh-vms-list.txt
