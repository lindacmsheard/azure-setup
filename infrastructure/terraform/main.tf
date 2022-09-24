# SET UP TERRAFORM AND SPECIFY PROVIDERS
# ======================================

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
# https://registry.terraform.io/providers/databrickslabs/databricks/latest/docs
# https://registry.terraform.io/providers/hashicorp/random/latest/docs
# check for the latest provider versions version here ^
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.20.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }
  
  # TERRAFORM STATE
  # Let's store Terraform State in Azure Storage, not on the machine that is executing terraform
  # https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage
  # Note: we can't use variables here: https://www.terraform.io/docs/language/settings/backends/azurerm.html
  #      Instead, we use a partial configuration: https://www.terraform.io/docs/language/settings/backends/configuration.html#partial-configuration
  #      To run it, run:

  #      terraform init -backend-config="KEY=<env.programme.project>.tfstate" 
  
  #      or, when all the items in the backend config below are commented, they can be supplied
  #      in a tfvars-like file:
        
  #      terraform init -backend-config='./demo-backend.tfvars'
  
  # Note also that no further authentication is required when executing via the CLI, if the identity 
  #      executing has access to this storage account
  
  backend "azurerm" {
    #resource_group_name   = "util"
    #storage_account_name  = "utilstorage"
    #container_name        = "terraform"
    #key                   = "main.lcmg.explore.common.tfstate"    # specify this on command line when running terraform init -backend=true (will prompt for key)
  }
}


# CONFIGURE PROVIDERS
# ===================

provider "azurerm" {
  features {}

  # Future: to authenticate with service principal instead of CLI:
  # Note: this SP would need contributor rights on the subscription, so that it can 
  #       create the project resource group, retrieve information about the resources 
  #       in the existing common resource group, and provision resource within that. 

  #client_id            = var.client_id
  #client_secret        = var.client_secret
  #tenant_id            = var.tenant_id
  #subscription_id      = var.subscription_id
}

# We also need the databricks resource provider to be able to specify clusters within workspaces


data "azurerm_client_config" "current" {}

# ensure we can operate on the keyvault we define later as this terraform client
resource "azurerm_key_vault_access_policy" "kv-access" {
  key_vault_id       = azurerm_key_vault.commonkv.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = data.azurerm_client_config.current.object_id
  secret_permissions = ["Get", "List", "Set", "Delete", "Recover","Backup", "Restore"]
}

# CREATE MAIN RESOURCE GROUP 
# ==========================

# This resource group will contain all other other resources created by this specification, specific to this repo

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
resource "azurerm_resource_group" "commonrg" {
  name     = "${var.common_rg_name}"
  location = var.location

  tags = {
    organisation = var.organisation
    programme = var.programme
    project = "${var.programme}-${var.project}"
    environment = var.env
    creationSource = "terraform"
  }
}

resource "azurerm_storage_account" "commonlake" {
  name                  = "${var.common_lake_name}"
  resource_group_name   = azurerm_resource_group.commonrg.name
  location              = azurerm_resource_group.commonrg.location
  account_tier          = "Standard"
  account_replication_type = "LRS"
  min_tls_version       = "TLS1_2"
  allow_nested_items_to_be_public = true
  
  is_hns_enabled = true

  tags = {
    organisation = var.organisation
    programme = var.programme
    project = "${var.programme}-${var.project}"
    environment = var.env
    creationSource = "terraform"
  }
}


resource "azurerm_storage_container" "bronze" {
  name                  = "bronze"
  storage_account_name  = azurerm_storage_account.commonlake.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "silver" {
  name                  = "silver"
  storage_account_name  = azurerm_storage_account.commonlake.name
  container_access_type = "private"
}

# This is a common storage account primarily used for landing data (e.g zip files), for ingestion in the lake
resource "azurerm_storage_account" "commonblob" {
  name                  = "${var.common_storage_name}"
  resource_group_name   = azurerm_resource_group.commonrg.name
  location              = azurerm_resource_group.commonrg.location
  account_tier          = "Standard"
  account_replication_type = "LRS"
  min_tls_version       = "TLS1_2"
  allow_nested_items_to_be_public = true


  tags = {
    organisation = var.organisation
    programme = var.programme
    project = "${var.programme}-${var.project}"
    environment = var.env
    creationSource = "terraform"
  }
}

resource "azurerm_storage_container" "sampledata" {
  name                  = "sampledata"
  storage_account_name  = azurerm_storage_account.commonblob.name
  container_access_type = "private"
}

# This is a common storage account used for utilities such as the cloud shell for the team, and to persist terraform states
resource "azurerm_key_vault" "commonkv" {
  name                        = "${var.common_keyvault_name}"
  resource_group_name         = azurerm_resource_group.commonrg.name
  location                    = azurerm_resource_group.commonrg.location
  enabled_for_disk_encryption = false
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 90
  purge_protection_enabled    = false

  sku_name = "standard"

  

  tags = {
      organisation = var.organisation
      programme = var.programme
      project = "${var.programme}-${var.project}"
      environment = var.env
      creationSource = "terraform"
  }
}

