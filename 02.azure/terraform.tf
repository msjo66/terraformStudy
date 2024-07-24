terraform {
  backend "azurerm" {
    container_name       = "tfstate"
    key                  = "myIaC" #blob file 명
    resource_group_name  = "rg-tfstate"
    storage_account_name = "msjo66sttfstateimport"
  }

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.99.0"

    }
  }
}
