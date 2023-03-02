terraform {
required_providers {
    azurerm = {
        source   = "hashicorp/azurerm"
        version  = "~> 3.45.0"
        }
    }
backend "azurerm" {
    resource_group_name = "DevOpsRG"
    storage_account_name = "devopsterraformstatesa"
    container_name = "tfstate\resource_group"
    key = "resource.group.tfstate"
}
}

provider "azurerm" {
    features {}
}