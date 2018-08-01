#!/bin/bash
set -e

. ./env/bin/activate

aws configure set aws_access_key_id $AWS_ACCESS_KEY
aws configure set aws_secret_access_key $AWS_SECRET_KEY
aws configure set region us-east-1
aws configure set output json

if [ -z "$REGIONS" ]; then
    REGIONS=$(aws ec2 describe-regions | jq -r '.Regions[].RegionName')
fi
for REGION in $REGIONS; do
    echo "Processing Region [$REGION]"
    aws configure set region "$REGION"

    # these have direct costs
    echo '    Terminating EC2 Instances...'
    aws ec2 describe-instances | jq -r '.Reservations[].Instances[].InstanceId' | xargs -r -n 1 aws ec2 terminate-instances --instance-ids
    DONE=$(aws ec2 describe-instances | jq -r '[.Reservations[].Instances[].State.Name == "terminated"] | all')
    while [ "$DONE" != "true" ]; do
        sleep 30
        DONE=$(aws ec2 describe-instances | jq -r '[.Reservations[].Instances[].State.Name == "terminated"] | all')
    done
    echo '    All EC2 instances have been shutdown.'

    echo '    Deleteing Volumes'
    aws ec2 describe-volumes | jq -r '.Volumes[].VolumeId' | xargs -r -n 1 aws ec2 delete-volume --volume-id
    echo '    All Volumes are gone'

    echo '    Releasing IP addresses...'
    aws ec2 describe-addresses | jq -r '.Addresses[].AllocationId' | xargs -r -n 1 aws ec2 release-address --allocation-id
    echo '    Public IPs are gone'

    echo '    Deleting ELBs...'
    aws elb describe-load-balancers | jq -r .LoadBalancerDescriptions[].LoadBalancerName | xargs -r -n 1 aws elb delete-load-balancer --load-balancer-name
    echo '    ELBs are gone'

    echo '    Deleting RDS instances...'
    aws rds describe-db-instances | jq -r '.DBInstances[].DBInstanceIdentifier' | xargs -r -n 1 aws rds delete-db-instance --skip-final-snapshot --db-instance-identifier
    DONE=$(aws rds describe-db-instances | jq -r '[.DBInstances[].DBInstanceStatus != "deleting"] | all')
    while [ "$DONE" != "true" ]; do
        sleep 30
        DONE=$(aws rds describe-db-instances | jq -r '[.DBInstances[].DBInstanceStatus != "deleting"] | all')
    done
    echo '    RDS instances are gone'

    echo '    Deleting S3 buckets...'
    BUCKETS=$(aws s3api list-buckets)
    echo "$BUCKETS" | jq -r '.Buckets[].Name | select(. | startswith("cf-"))' | xargs -r -I{} -n 1 aws s3 rb --force "s3://{}"
    echo "$BUCKETS" | jq -r '.Buckets[].Name | select(. | startswith("pcf-"))' | xargs -r -I{} -n 1 aws s3 rb --force "s3://{}"
    echo '    S3 buckets gone'

    # these don't necessarily have costs associated
    echo '    Deleting security groups...'
    aws ec2 describe-security-groups | jq -r '.SecurityGroups[] | select(.GroupName != "default") | .GroupId' | xargs -r -n 1 aws ec2 delete-security-group --group-id
    echo '    Security groups gone'

    echo '    Deleting key pairs...'
    aws ec2 describe-key-pairs | jq -r '.KeyPairs[].KeyName' | xargs -r -n 1 aws ec2 delete-key-pair --key-name
    echo '    Key pairs gone'

    echo '    Deleting subnets...'
    aws ec2 describe-subnets | jq -r '.Subnets[].SubnetId' | xargs -r -n 1 aws ec2 delete-subnet --subnet-id
    echo '    Subnets gone'

    echo '    Deleting network ACLs...'
    aws ec2 describe-network-acls | jq -r '.NetworkAcls[] | select(.IsDefault == "false") | .NetworkAclId' | xargs -r -n 1 aws ec2 delete-network-acl --network-acl-id
    echo '    Network ACLs are gone'

    echo '    Deleting route tables...'
    aws ec2 describe-route-tables | ./parse-route-tables.py | xargs -r -n 1 aws ec2 delete-route-table --route-table-id
    echo '    Route tables gone'

    echo '    Deleting Internet Gateways...'
    aws ec2 describe-internet-gateways | ./parse-internet-gateways.py | xargs -r -I{} -0 -n 1 bash -c "aws ec2 {}"
    echo '    Internet gateways gone'

    # has to happen last
    echo '    Deleting VPCs...'
    aws ec2 describe-vpcs | jq -r '.Vpcs[].VpcId' | xargs -r -n 1 aws ec2 delete-vpc --vpc-id
    echo '    VCPs are gone'

    echo '    Deleting CloudFormation Stacks...'
    aws cloudformation list-stacks | jq -r '.StackSummaries[] | select(.StackStatus != "DELETE_COMPLETE") | .StackName' | xargs -r -n 1 aws cloudformation delete-stack --stack-name
    echo '    CloudFormation stacks gone'
done

# monitor only
#aws iam list-users > "$DATADIR/users.json"
