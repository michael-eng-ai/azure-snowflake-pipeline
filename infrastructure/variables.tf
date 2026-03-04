variable "location" {
  description = "Azure Region for the deployment"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "rg-snowflake-pipeline"
}

variable "storage_account_name" {
  description = "Name of the Storage Account (Must be globally unique, max 24 lowercase letters/numbers)"
  type        = string
  default     = "stdatalakesnowflake"
}
