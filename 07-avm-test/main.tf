terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  
  features {
  }
}

module "ktRegionSelector" {
  source = "./modules/kt-regions"
  geography = "Korea"
}

locals {
  location = module.ktRegionSelector.two_regions_with_zones[0].name
}

output "location" {
  value = local.location
}