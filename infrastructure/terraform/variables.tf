# https://learn.hashicorp.com/tutorials/terraform/variables?in=terraform/configuration-language
variable "location" {
  description = "Azure region"
  type        = string
  default     = "uksouth"
}

variable "organisation" {
  description = "org specifier used in tags and optionally in resource group naming convention - keep short"
  type        = string
  default     = "lcmg"
}

# Note: edit the guidance in ./assets/Welcome.py if editing project or programme name
variable "programme" {
  description = "Programme Name"
  type        = string
  default     = "explore"
}

variable "common_rg_name" {
  description = "Name of the resource group with resources common to the programme"
  type        = string
  default     = "explore"
}

variable "common_lake_name" {
  description = "Name of the datalake with data common to the programme"
  type        = string
  default     = "lcmgexplorelake"
}

variable "common_storage_name" {
  description = "Name of the storage account with data common to the programme"
  type        = string
  default     = "lcmgexploreblob"
}

variable "common_keyvault_name" {
  description = "Name of the keyvault that can be used to supply secrets to this terraform spec"
  type        = string
  default     = "lcmg-kv"
}

variable "project" {
  description = "Project Name"
  type        = string
  default     = "common"
}

variable "suffix" {
  description = "Suffix that can be used on resource names"
  type        = string
  default     = "-TMP-DO-NOT-USE"
}

variable "env" {
  description = "Prefix to distinguish environments and avoid naming conflicts when deploying in multiple locations"
  type = string
  default = "main"
}