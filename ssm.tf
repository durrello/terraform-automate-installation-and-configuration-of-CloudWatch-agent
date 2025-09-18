resource "aws_ssm_parameter" "cw_agent_config_linux" {
  name = "AmazonCloudWatch-linux"
  type = "String"
  value = jsonencode({
    agent = {
      metrics_collection_interval = 60
      run_as_user                 = "cwagent"
    }
    metrics = {
      namespace = "CWAgent"
      metrics_collected = {
        cpu = {
          measurement = [
            "cpu_usage_idle",
            "cpu_usage_iowait",
            "cpu_usage_user",
            "cpu_usage_system"
          ]
          metrics_collection_interval = 60
          resources                   = ["*"]
          totalcpu                    = false
        }
        disk = {
          measurement                 = ["used_percent"]
          metrics_collection_interval = 60
          resources                   = ["*"]
        }
        diskio = {
          measurement = [
            "io_time",
            "read_bytes",
            "write_bytes",
            "reads",
            "writes"
          ]
          metrics_collection_interval = 60
          resources                   = ["*"]
        }
        mem = {
          measurement                 = ["mem_used_percent"]
          metrics_collection_interval = 60
        }
        netstat = {
          measurement                 = ["tcp_established", "tcp_time_wait"]
          metrics_collection_interval = 60
        }
        swap = {
          measurement                 = ["swap_used_percent"]
          metrics_collection_interval = 60
        }
      }
    }
    logs = {
      logs_collected = {
        files = {
          collect_list = [
            {
              file_path       = "/var/log/messages"
              log_group_name  = aws_cloudwatch_log_group.linux_messages.name
              log_stream_name = "{instance_id}"
              timezone        = "UTC"
            }
          ]
        }
      }
    }
  })

  depends_on = [aws_cloudwatch_log_group.linux_messages]
}

resource "aws_ssm_parameter" "cw_agent_config_windows" {
  name = "AmazonCloudWatch-windows"
  type = "String"

  value = jsonencode({
    agent = {
      metrics_collection_interval = 60
    }
    metrics = {
      namespace = "CWAgent"
      append_dimensions = {
        InstanceId = "$${aws:InstanceId}"
      }
      aggregation_dimensions = [
        ["InstanceId"]
      ],
      metrics_collected = {
        LogicalDisk = {
          measurement = [
            "% Free Space",
            "Free Megabytes"
          ],
          resources = [
            "*"
          ],
          metrics_collection_interval = 60
        },
        Memory = {
          measurement = [
            "% Committed Bytes In Use",
            "Available MBytes"
          ],
          metrics_collection_interval = 60
        },
        Paging_File = {
          measurement = [
            "% Usage"
          ],
          metrics_collection_interval = 60
        },
        CPU = {
          measurement = [
            "% Idle Time",
            "% Interrupt Time",
            "% Privileged Time",
            "% User Time",
            "% Processor Time"
          ],
          metrics_collection_interval = 60,
          totalcpu                    = true
        },
        System = {
          measurement = [
            "System Up Time"
          ],
          metrics_collection_interval = 60
        }
      }
    }
    logs = {
      logs_collected = {
        files = {
          collect_list = [
            {
              file_path       = "C:\\Windows\\System32\\LogFiles\\*.log"
              log_group_name  = aws_cloudwatch_log_group.windows_logs.name
              log_stream_name = "{instance_id}"
              timezone        = "UTC"
            }
          ]
        }
        windows_events = {
          collect_list = [
            {
              event_format = "xml"
              event_levels = [
                "VERBOSE",
                "INFORMATION",
                "WARNING",
                "ERROR",
                "CRITICAL"
              ]
              event_name      = "System"
              log_group_name  = aws_cloudwatch_log_group.windows_logs.name
              log_stream_name = "{instance_id}/System"
            },
            {
              event_format = "xml"
              event_levels = [
                "VERBOSE",
                "INFORMATION",
                "WARNING",
                "ERROR",
                "CRITICAL"
              ]
              event_name      = "Application"
              log_group_name  = aws_cloudwatch_log_group.windows_logs.name
              log_stream_name = "{instance_id}/Application"
            }
          ]
        }
      }
    }
  })

  depends_on = [aws_cloudwatch_log_group.windows_logs]
}