resource "aws_dynamodb_table" "table" {
  name         = "${var.dynamodb_table_name}-${var.environment}"
  billing_mode = var.billing_mode # PAY_PER_REQUEST or PROVISIONED
  hash_key     = var.hash_key     # partition key for table
  # enable read/write capacity autoscaling only for PROVISIONED mode
  read_capacity  = var.billing_mode == "PROVISIONED" ? 1 : null
  write_capacity = var.billing_mode == "PROVISIONED" ? 1 : null

  attribute {
    name = var.hash_key
    type = "S"
  }
  # enable server-side encryption (AWS owned CMK by default)
  server_side_encryption {
    enabled = true
  }
  # enable Point-in-Time Recovery (PITR) for data protection
  point_in_time_recovery {
    enabled = true
  }

  deletion_protection_enabled = true
  lifecycle {
    ignore_changes = [
      deletion_protection_enabled
    ]
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}

# autoscaling for PROVISIONED mode only
resource "aws_appautoscaling_target" "read" {
  count              = var.enable_autoscaling && var.billing_mode == "PROVISIONED" ? 1 : 0
  max_capacity       = var.autoscaling_max_capacity
  min_capacity       = var.autoscaling_min_capacity
  resource_id        = "table/${aws_dynamodb_table.table.name}" # attach to this dynamodb table
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"       # required - Scalable dimension of the scalable target
  service_namespace  = "dynamodb"                               # required - AWS service namespace of the scalable target
}

resource "aws_appautoscaling_policy" "read" {
  count              = var.enable_autoscaling && var.billing_mode == "PROVISIONED" ? 1 : 0
  name               = "${var.dynamodb_table_name}-Read-Autoscaling-Policy"
  policy_type        = "TargetTrackingScaling"                              # required by target_tracking_scaling_policy_configuration
  resource_id        = aws_appautoscaling_target.read[0].resource_id        # attach to aws_appautoscaling_target.read
  scalable_dimension = aws_appautoscaling_target.read[0].scalable_dimension # required - Scalable dimension of the scalable target
  service_namespace  = aws_appautoscaling_target.read[0].service_namespace  # required - AWS service namespace of the scalable target

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      # cloudwatch metric to measure the percentage of provisioned read capacity units 
      # that the table is currently using
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value       = var.autoscaling_target_utilization # percent
    scale_in_cooldown  = 60                                 # sec
    scale_out_cooldown = 60                                 # sec
  }
}

resource "aws_appautoscaling_target" "write" {
  count              = var.enable_autoscaling && var.billing_mode == "PROVISIONED" ? 1 : 0
  max_capacity       = var.autoscaling_max_capacity
  min_capacity       = var.autoscaling_min_capacity
  resource_id        = "table/${aws_dynamodb_table.table.name}" # attach to aws_appautoscaling_target.write
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"      # required - Scalable dimension of the scalable target
  service_namespace  = "dynamodb"                               # required - AWS service namespace of the scalable target
}

resource "aws_appautoscaling_policy" "write" {
  count              = var.enable_autoscaling && var.billing_mode == "PROVISIONED" ? 1 : 0
  name               = "${var.dynamodb_table_name}-WriteAutoScalingPolicy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.write[0].resource_id        # attach to aws_appautoscaling_target.write
  scalable_dimension = aws_appautoscaling_target.write[0].scalable_dimension # required - Scalable dimension of the scalable target
  service_namespace  = aws_appautoscaling_target.write[0].service_namespace  # required - AWS service namespace of the scalable target

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      # cloudwatch metric to measure the percentage of provisioned write capacity units 
      # that the table is currently using
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value       = var.autoscaling_target_utilization # percent
    scale_in_cooldown  = 60                                 # sec
    scale_out_cooldown = 60                                 # sec
  }
}