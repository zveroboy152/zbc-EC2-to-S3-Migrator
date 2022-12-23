# EC2 to S3 Migrator

A command-line utility for exporting stopped Amazon Elastic Compute Cloud (EC2) instances to an Amazon Simple Storage Service (S3) bucket.

## Steps

1. Select the region to scan for instances:
   - us-east-1
   - us-east-2
   - us-west-1
   - us-west-2
   - ap-south-1
   - ap-northeast-2
   - ap-southeast-1
   - ap-southeast-2
   - ap-northeast-1
   - ca-central-1
   - eu-central-1
   - eu-west-1
   - eu-west-2
   - eu-west-3
   - eu-north-1
   - sa-east-1
2. Enter the name of the S3 bucket.
3. Review the list of stopped EC2 instances in the selected region.
4. Confirm whether you want to continue and export the listed instances to the S3 bucket.
5. If confirmed, the script will create a configuration file for the export tasks and then loop through the list of instances, exporting each one to the S3 bucket using the `aws ec2 create-instance-export-task` command.
6. Once the loop completes, the script will clean up the export task configuration file and print a list of the instances that were exported to the S3 bucket.
