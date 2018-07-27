#!/bin/bash
set -e

az login --tenant "$AZURE_TENANT"

VMS=$(az vm list | jq -r '.[].id')
echo "Cleaning up VMs..."
for VM in $VMS; do
    echo "  Starting stop & delete of VM [$VM]"
    az vm stop --no-wait --ids $VM
    az vm delete --no-wait --yes --ids $VM
done
for VM in $VMS; do
    echo "Waiting for [$VM] to finish shutting down & deleting..."
    az vm wait --deleted --ids $VM
done
echo "VMs are gone"

RGS=$(az group list | jq -r '.[] | select(.name != "us-east-team-dns") | select(.name != "us-west-team-dns") | .name')
for RG in $RGS; do
    echo "Cleaning up availability sets in resource group [$RG]..."
    AZSETS=$(az vm availability-set list --resource-group "$RG" | jq -r '.[].id')
    if [ "$AZSETS" != "" ]; then
        az vm availability-set delete --ids $AZSETS
    fi
    echo "Availability sets are gone from [$RG]"
done

echo "Cleaning up NICs..."
NICS=$(az network nic list | jq -r '.[].id')
if [ "$NICS" != "" ]; then
    az network nic delete --ids $NICS
fi
echo "NICs are gone"

echo "Cleaning up LBs..."
LBS=$(az network lb list | jq -r '.[].id')
if [ "$LBS" != "" ]; then
    az network lb delete --ids $LBS
fi
echo "LBs are gone"

echo "Cleaning up public IPs..."
IPS=$(az network public-ip list | jq -r '.[].id')
if [ "$IPS" != "" ]; then
    az network public-ip delete --ids $IPS
fi
echo "Public IPs are gone"

echo "Cleaning up virtual networks..."
VNETS=$(az network vnet list | jq -r '.[].id')
if [ "$VNETS" != "" ]; then
    az network vnet delete --ids $VNETS
fi
echo "Virtual networks are gone"

echo "Cleaning up network security groups..."
NSGS=$(az network nsg list | jq -r '.[].id')
if [ "$NSGS" != "" ]; then
    az network nsg delete --ids $NSGS
fi
echo "Network Security Groups are gone"

echo "Cleaning up storage accounts..."
STACS=$(az storage account list | jq -r '.[].id')
if [ "$STACS" != "" ]; then
    az storage account delete --yes --ids $STACS
fi
echo "Storage accounts are gone"

echo "Deleting resource groups"
RGS=$(az group list | jq -r '.[] | select(.name != "us-east-team-dns") | select(.name != "us-west-team-dns") | .name')
for RG in $RGS; do
    az group delete --name "$RG" --yes
done
echo "Resource groups gone"
