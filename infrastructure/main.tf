terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Azure Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "prod"
    ManagedBy   = "Terraform"
    Project     = "azure-snowflake-pipeline"
  }
}

# Azure Storage Account Gen2 (Hierarchical Namespace Enabled)
resource "azurerm_storage_account" "datalake" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # CRITICAL: Enable Hierarchical Namespace for ADLS Gen2
  is_hns_enabled = true

  tags = {
    Environment = "prod"
    ManagedBy   = "Terraform"
    Project     = "azure-snowflake-pipeline"
  }
}

# Storage Container (File System in Gen2)
resource "azurerm_storage_data_lake_gen2_filesystem" "raw_data" {
  name               = "raw-data"
  storage_account_id = azurerm_storage_account.datalake.id
}
