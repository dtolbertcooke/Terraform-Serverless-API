variable "environment" {
  description = "Environment (dev, test, prod) for resources"
  type        = string
  default     = "dev"
}
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "default_project"
}
variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "default_owner"
}
variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for app data"
  type        = string
}
variable "hash_key" {
  description = "Hash key for the DynamoDB table"
  type        = string
}
variable "billing_mode" {
  description = "Billing mode for the DynamoDB table"
  type        = string
  default     = "PAY_PER_REQUEST"
}
variable "enable_autoscaling" {
  description = "Enable autoscaling for the table?"
  type        = bool
  default     = false
}

variable "autoscaling_min_capacity" {
  description = "Min provisioned capacity for autoscaling"
  type        = number
  default     = 5
}

variable "autoscaling_max_capacity" {
  description = "Max provisioned capacity for autoscaling"
  type        = number
  default     = 100
}

variable "autoscaling_target_utilization" {
  description = "Target utilization percentage for autoscaling"
  type        = number
  default     = 66 # 2/3 max capacity
}