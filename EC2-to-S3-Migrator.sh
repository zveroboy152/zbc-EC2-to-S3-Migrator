#!/bin/bash

echo " _____ _____ _____ _____ _____ _____ _____ _____ "
echo "   EC2 to S3 Migrator 
Prior to running this script, be sure you do the following in your AWS S3 bucket:
1. Add Grantee, Region-specific canonical account ID to S3 ACL with read/write permission
2. Navigate to: Amazon S3 -> Buckets -> yourbucketname -> permissions -> Access control list (ACL) -> Edit
3. Find section named: Access for other AWS accounts, add relevant canonical account ID and permissions
Documentation: https://docs.aws.amazon.com/vm-import/latest/userguide/vmexport.html"
echo " _____ _____ _____ _____ _____ _____ _____ _____ "

# CLI based choice list to select between ALL AWS US regions
echo "Select the region to scan for instances:"
echo "1. us-east-1"
echo "2. us-east-2"
echo "3. us-west-1"
echo "4. us-west-2"
echo "5. ap-south-1"
echo "6. ap-northeast-2"
echo "7. ap-southeast-1"
echo "8. ap-southeast-2"
echo "9. ap-northeast-1"
echo "10. ca-central-1"
echo "11. eu-central-1"
echo "12. eu-west-1"
echo "13. eu-west-2"
echo "14. eu-west-3"
echo "15. eu-north-1"
echo "16. sa-east-1"
read -p "Enter the number corresponding to the region: " region_num

case $region_num in
  1) region=us-east-1;;
  2) region=us-east-2;;
  3) region=us-west-1;;
  4) region=us-west-2;;
  5) region=ap-south-1;;
  6) region=ap-northeast-2;;
  7) region=ap-southeast-1;;
  8) region=ap-southeast-2;;
  9) region=ap-northeast-1;;
  10) region=ca-central-1;;
  11) region=eu-central-1;;
  12) region=eu-west-1;;
  13) region=eu-west-2;;
  14) region=eu-west-3;;
  15) region=eu-north-1;;
  16) region=sa-east-1;;
  *) echo "Invalid input. Please enter a number from 1 to 16."; exit 1;;
esac

# Set the prefix to use for the exported instances in the S3 bucket (the container in the bucket)
s3_prefix=/

# Set the prefix to use for the exported instances in the S3 bucket
read -p "Enter the name of the S3 bucket: " bucket_name

# Check that lists all powered OFF VMs in the selected AWS US region with a yes/no continuation prompt (with error checking for input)
echo "The following instances are currently powered off in the $region region:"
aws ec2 describe-instances --region $region --filters "Name=instance-state-name,Values=stopped" --query "Reservations[*].Instances[*].[InstanceId]" --output text
read -p "Do you want to continue and export these instances to the S3 bucket? (y/n) " choice
while true; do
  case $choice in
    [Yy]* ) break;;
    [Nn]* ) exit;;
    * ) echo "Please enter y or n.";;
  esac
done

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

# Print to the screen what happened
echo "Exported the following instances to the $bucket_name S3 bucket in the $region region:"
echo $instances
echo "This export can take from 1 - 6 hours"
