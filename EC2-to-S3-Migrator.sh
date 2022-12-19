#!/bin/bash

#Permissions to set on the S3 bucket taht YOU created:

#added Grantee, Region-specific canonical account ID to S3 ACL with read/write permission

#Navigate to: Amazon S3 -> Buckets -> yourbucketname -> permissions -> Access control list (ACL) -> Edit

#Find section named: Access for other AWS accounts, add relevant canonical account ID and permissions

#After adding canonical account ID: enter image description here

#Find relevent grantee by ref:

#https://docs.aws.amazon.com/vm-import/latest/userguide/vmexport.html

# Set the region to scan for instances

region=us-east-2

# Set the prefix to use for the exported instances in the S3 bucket (the container in the bucket)
s3_prefix=vms/

# Generate a unique name for the S3 bucket
bucket_name=
 
# Create the export task configuration file
cat > export_task_config.json << EOF
{
    "ContainerFormat": "ova",
    "DiskImageFormat": "VMDK",
    "S3Bucket": "$bucket_name",
    "S3Prefix": "$s3_prefix"
}
EOF

# Get a list of all stopped EC2 instances in the specified region
instances=$(aws ec2 describe-instances --region $region --filters "Name=instance-state-name,Values=stopped" --query "Reservations[*].Instances[*].[InstanceId]" --output text)

# Loop through the list of instances and export each one to the S3 bucket
for instance in $instances; do
  aws ec2 create-instance-export-task --instance-id $instance --target-environment vmware --export-to-s3-task file://export_task_config.json --region $region
done

# Clean up the export task configuration file
rm export_task_config.json
