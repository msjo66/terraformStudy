terraform {
  required_version = "> 1.3.0" # 물결표시는 가장 자리수가 낮은 부분에 대해서라는 뜻. 따라서 ~> 1.3.0은 1.3.x는 허용한다는 뜻
  
  # backend "azurerm" {
  #   container_name       = "tfstate"
  #   key                  = "myIaC" #blob file 명
  #   resource_group_name  = "rg-tfstate"
  #   storage_account_name = "msjo66sttfstateimport"
  # }
  backend "local" {
    path = "state/terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.99.0"

    }
  }
}
