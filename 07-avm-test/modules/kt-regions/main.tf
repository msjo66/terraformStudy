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

output "two_regions_with_zones" {
  value       = [for v in module.regions.regions : v if contains(random_shuffle.two_region_names_with_zones.result, v.name)]
  description = "Outputs two random Korea regions with zones."
}