#!/bin/bash

# Set the name of the S3 bucket
BUCKET_NAME=my-s3-bucket

# Check if the S3 bucket exists, and create it if it doesn't
if ! aws s3 ls "s3://$BUCKET_NAME" > /dev/null 2>&1; then
  aws s3 mb "s3://$BUCKET_NAME"
fi

# Get the IDs of all turned off EC2 instances
INSTANCE_IDS=$(aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=stopped" \
  --query "Reservations[*].Instances[*].InstanceId" \
  --output text)

# Iterate over the instance IDs and move each instance to the S3 bucket
for INSTANCE_ID in $INSTANCE_IDS; do
  aws s3 cp s3://$BUCKET_NAME/$INSTANCE_ID.tar.gz s3://$BUCKET_NAME/
done

# Print the final result
echo "Successfully moved all turned off EC2 instances to S3 bucket '$BUCKET_NAME'"
