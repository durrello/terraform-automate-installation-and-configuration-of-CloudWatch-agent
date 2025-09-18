# Terraform AWS CloudWatch Agent Automation

This repository contains Terraform code to automate the installation and configuration of the AWS CloudWatch Agent on Amazon EC2 instances using AWS Systems Manager (SSM). It supports both Linux and Windows EC2 instances configured via SSM parameters and associations, making centralized monitoring effortless.

## Features

- Creates IAM role and instance profile for EC2 with appropriate policies for SSM and CloudWatch Agent.
- Defines CloudWatch log groups for Linux and Windows logs.
- Provides SSM parameters for CloudWatch Agent configuration for both Linux and Windows.
- Creates an encrypted, versioned S3 bucket for storing SSM association logs with lifecycle policies.
- Automates CloudWatch Agent installation and configuration using SSM Associations.
- Provisions a CloudWatch dashboard for monitoring CPU, memory, and disk usage metrics for EC2 instances.
- Supports targeting instances by tags (`cloudwatch=enabled`, `os=Linux` or `os=Windows`).

## Getting Started

### Prerequisites

- Terraform 1.0 or later
- AWS CLI configured with sufficient permissions
- EC2 instances tagged for monitoring with:
  - `cloudwatch: enabled`
  - `os: Linux` or `os: Windows`
- EC2 instances associated with the IAM instance profile created by this module

### Usage

1. Clone this repository:

   ```
   git clone https://github.com/your-org/terraform-cloudwatch-agent-automation.git
   cd terraform-cloudwatch-agent-automation
   ```

2. Initialize Terraform:

   ```
   terraform init
   ```

3. Review and customize variables as needed, especially AWS region and partition.

4. Apply the Terraform configuration:

   ```
   terraform apply
   ```

5. Tag your EC2 instances appropriately and attach the output IAM instance profile:

   ```
   aws ec2 create-tags --resources <instance-id> --tags Key=cloudwatch,Value=enabled Key=os,Value=Linux
   aws ec2 associate-iam-instance-profile --instance-id <instance-id> --iam-instance-profile Name=<iam_instance_profile_name>
   ```

6. Monitor EC2 metrics and logs through the provisioned CloudWatch dashboard.

## Outputs

| Output                    | Description                                      |
|---------------------------|------------------------------------------------|
| `iam_instance_profile_name` | Name of IAM instance profile to attach to EC2 |
| `ssm_associations`          | IDs of the CloudWatch Agent SSM Associations   |
| `required_tags`             | Tags required to trigger CloudWatch agent installation (`cloudwatch=enabled`) |
| `cloudwatch_config_parameters` | Names of SSM parameters for Linux and Windows configurations |
| `ssm_logs_bucket`           | S3 bucket name for storing SSM association logs |

## Contributing
Contributions are welcome! Please open issues or pull requests to improve or extend this module.

Happy monitoring your EC2 fleet with centralized CloudWatch Agent automation!