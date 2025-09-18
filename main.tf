# SSM Association to install the CloudWatch Agent
resource "aws_ssm_association" "install_cloudwatch_agent" {
  name             = "AWS-ConfigureAWSPackage"
  association_name = "Install-CloudWatch-Agent"

  parameters = {
    action = "Install"
    name   = "AmazonCloudWatchAgent"
  }

  targets {
    key    = "tag:cloudwatch"
    values = ["enabled"]
  }

  schedule_expression = "rate(30 minutes)"
  max_concurrency     = "50%"
  max_errors          = "5%"

  output_location {
    s3_bucket_name = aws_s3_bucket.ssm_logs.bucket
    s3_key_prefix  = "install-logs"
  }
}

# SSM Association using the custom SSM Document
# Linux config association
resource "aws_ssm_association" "configure_cloudwatch_agent_linux" {
  name             = "AmazonCloudWatch-ManageAgent"
  association_name = "Configure-CloudWatch-Agent-Linux"

  parameters = {
    action                        = "configure"
    mode                          = "ec2"
    optionalRestart               = "yes"
    optionalConfigurationSource   = "ssm"
    optionalConfigurationLocation = aws_ssm_parameter.cw_agent_config_linux.name
  }

  targets {
    key    = "tag:cloudwatch"
    values = ["enabled"]
  }
  targets {
    key    = "tag:os"
    values = ["Linux"]
  }

  schedule_expression = "rate(40 minutes)"
  depends_on = [
    aws_ssm_association.install_cloudwatch_agent
  ]
}

# Windows config association
resource "aws_ssm_association" "configure_cloudwatch_agent_windows" {
  name             = "AmazonCloudWatch-ManageAgent"
  association_name = "Configure-CloudWatch-Agent-Windows"

  parameters = {
    action                        = "configure"
    mode                          = "ec2"
    optionalRestart               = "yes"
    optionalConfigurationSource   = "ssm"
    optionalConfigurationLocation = aws_ssm_parameter.cw_agent_config_windows.name
  }

  targets {
    key    = "tag:cloudwatch"
    values = ["enabled"]
  }
  targets {
    key    = "tag:os"
    values = ["Windows"]
  }

  schedule_expression = "rate(40 minutes)"
  depends_on = [
    aws_ssm_association.install_cloudwatch_agent
  ]
}

resource "aws_cloudwatch_dashboard" "ec2_monitoring" {
  dashboard_name = "EC2-CloudWatch-Agent-Metrics"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["CWAgent", "cpu_usage_user", "InstanceId", "*"],
            [".", "cpu_usage_system", ".", "."],
            [".", "cpu_usage_idle", ".", "."],
            [".", "cpu_usage_iowait", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "CPU Usage"
          period  = 300
          stat    = "Average"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["CWAgent", "mem_used_percent", "InstanceId", "*"],
            [".", "swap_used_percent", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Memory Usage"
          period  = 300
          stat    = "Average"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["CWAgent", "disk_used_percent", "InstanceId", "*", "device", "/dev/xvda1", "fstype", "xfs", "path", "/"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Disk Usage"
          period  = 300
          stat    = "Average"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      }
    ]
  })
}
