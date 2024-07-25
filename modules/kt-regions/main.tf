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

module "regions" {
  source = "Azure/regions/azurerm"
  version = "~> 0.3"
  use_cached_data = true
}

locals {
  regions_with_zones = [
    for v in module.regions.regions_by_geography[var.geography] : v if v.zones != null
  ]
}

resource "random_shuffle" "two_region_names_with_zones" {
  input        = [for v in local.regions_with_zones : v.name]
  result_count = 2
}