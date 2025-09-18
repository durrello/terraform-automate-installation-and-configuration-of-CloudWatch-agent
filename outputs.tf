# Additional output for the associations
output "ssm_associations" {
  description = "SSM Association details"
  value = {
    install           = aws_ssm_association.install_cloudwatch_agent.association_id
    configure_linux   = aws_ssm_association.configure_cloudwatch_agent_linux.association_id
    configure_windows = aws_ssm_association.configure_cloudwatch_agent_windows.association_id
  }
}

output "iam_instance_profile_name" {
  description = "IAM Instance Profile name to attach to EC2 instances"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "required_tags" {
  description = "Tags required on EC2 instances for CloudWatch agent installation"
  value = {
    cloudwatch = "enabled"
  }
}

output "cloudwatch_config_parameters" {
  description = "SSM Parameter names for CloudWatch configurations"
  value = {
    linux   = aws_ssm_parameter.cw_agent_config_linux.name
    windows = aws_ssm_parameter.cw_agent_config_windows.name
  }
}

output "ssm_logs_bucket" {
  description = "S3 bucket for SSM association logs"
  value       = aws_s3_bucket.ssm_logs.bucket
}