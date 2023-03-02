variable "resource_group_name" {
    description = "The name to assign to this resource group"
    type = string
    default = "rg-my-tf-resourcegroup"
}

variable "resource_group_location" {
    description = "Azure region to deploy into"
    type = string
    default = "eastus"
}

# variable "tf_state_resource_group_name" {
#     description = "The resource group name which contains the storage account to store Terraform state"
#     type = string
#     default = "devopsterraformstatesa"
# }

# variable "tf_state_storage_account_name" {
#     description = "The storage account name to store Terraform state"
#     type = string
#     default = "devopsterraformstatesa"
# }

# variable "tf_state_container_name" {
#     description = "The container in the storage account to store the Terraform state in"
#     type = string
#     default = "tfstate"
# }

variable "tags" {
    description = "The tags to assign to this resource"
    default = {
        department = "DevOps"
        environment = "Development"
    }
}