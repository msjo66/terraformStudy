provider "azurerm" {
  features {}
}

# 1. state를 저장할 곳을 azure storage account에 준비한다.
#az group create -l koreacentral -n rg-tfstate #rg-tfstate == resourcegroup-terraform-state
#az storage account create -n msjo66sttfstateimport -g rg-tfstate #sttfstateimport == storage-terraform-state-import
#az storage container create -n tfstate --account-name msjo66sttfstateimport # tfstate == terraform-state

terraform {
  backend "azurerm" {
    container_name       = "tfstate"
    key                  = "myIaC" #blob file 명
    resource_group_name  = "rg-tfstate"
    storage_account_name = "msjo66sttfstateimport"
  }
}

# 2. terraform init을 통해 위 tfstate container에 'myIaC'라는 이름으로 state file을 저장(생성)한다.

# 3. import 하고자 하는 리소스를 모두 찾는다.
# az resource list --resource-group kt-cn-edu-rg --query "[].{name:name resourceGroup:resourceGroup type:type id:id}"

# 4. 위 찾은 resource들을 state로 import한다.
import {
   to = azurerm_resource_group.kt-cn-edu-rg
   id = "/subscriptions/0c3cf580-73d2-4b42-9db8-c3517e198afc/resourceGroups/kt-cn-edu-rg"
}
import {
   to = azurerm_virtual_network.VNet1
   id = "/subscriptions/0c3cf580-73d2-4b42-9db8-c3517e198afc/resourceGroups/kt-cn-edu-rg/providers/Microsoft.Network/virtualNetworks/VNet1"
}
import {
   to = azurerm_route_table.VNet1-route-table
   id = "/subscriptions/0c3cf580-73d2-4b42-9db8-c3517e198afc/resourceGroups/kt-cn-edu-rg/providers/Microsoft.Network/routeTables/VNet1-route-table"
}

import {
  to = azurerm_subnet.AzureBastionSubnet
  id = "/subscriptions/0c3cf580-73d2-4b42-9db8-c3517e198afc/resourceGroups/kt-cn-edu-rg/providers/Microsoft.Network/virtualNetworks/VNet1/subnets/AzureBastionSubnet"
}

import {
  to = azurerm_subnet.DBSubnet
  id = "/subscriptions/0c3cf580-73d2-4b42-9db8-c3517e198afc/resourceGroups/kt-cn-edu-rg/providers/Microsoft.Network/virtualNetworks/VNet1/subnets/DBSubnet"
}

import {
  to = azurerm_subnet.WasSubnetName
  id = "/subscriptions/0c3cf580-73d2-4b42-9db8-c3517e198afc/resourceGroups/kt-cn-edu-rg/providers/Microsoft.Network/virtualNetworks/VNet1/subnets/WasSubnetName"
}

# import {
#   to = azurerm_subnet_route_table_association.DBSubnetAssoc
#   id = "/subscriptions/0c3cf580-73d2-4b42-9db8-c3517e198afc/resourceGroups/kt-cn-edu-rg/providers/Microsoft.Network/virtualNetworks/VNet1/subnets/DBSubnet/routeTables/L3N1YnNjcmlwdGlvbnMvMGMzY2Y1ODAtNzNkMi00YjQyLTlkYjgtYzM1MTdlMTk4YWZjL3Jlc291cmNlR3JvdXBzL2t0LWNuLWVkdS1yZy9wcm92aWRlcnMvTWljcm9zb2Z0Lk5ldHdvcmsvcm91dGVUYWJsZXMvVk5ldDEtcm91dGUtdGFibGU="
# }

# import {
#   to = azurerm_subnet_route_table_association.WasSubnetAssoc
#   id = "/subscriptions/0c3cf580-73d2-4b42-9db8-c3517e198afc/resourceGroups/kt-cn-edu-rg/providers/Microsoft.Network/virtualNetworks/VNet1/subnets/WasSubnetName/routeTables/L3N1YnNjcmlwdGlvbnMvMGMzY2Y1ODAtNzNkMi00YjQyLTlkYjgtYzM1MTdlMTk4YWZjL3Jlc291cmNlR3JvdXBzL2t0LWNuLWVkdS1yZy9wcm92aWRlcnMvTWljcm9zb2Z0Lk5ldHdvcmsvcm91dGVUYWJsZXMvVk5ldDEtcm91dGUtdGFibGU="
# }

# 5. resource들을 여기에 다시 기입한다.
resource "azurerm_resource_group" "kt-cn-edu-rg" {
  location = "koreacentral"
  name     = "kt-cn-edu-rg"
}
resource "azurerm_virtual_network" "VNet1" {
  address_space       = ["10.0.0.0/16"]
  location            = "koreacentral"
  name                = "VNet1"
  resource_group_name = "kt-cn-edu-rg"
  depends_on = [
    azurerm_resource_group.kt-cn-edu-rg,
  ]
}
resource "azurerm_route_table" "VNet1-route-table" {
  location            = "koreacentral"
  name                = "VNet1-route-table"
  resource_group_name = "kt-cn-edu-rg"
  depends_on = [
    azurerm_resource_group.kt-cn-edu-rg,
  ]
}
resource "azurerm_subnet" "AzureBastionSubnet" {
  address_prefixes     = ["10.0.0.0/26"]
  name                 = "AzureBastionSubnet"
  resource_group_name  = "kt-cn-edu-rg"
  virtual_network_name = "VNet1"
  depends_on = [
    azurerm_virtual_network.VNet1,
  ]
}
resource "azurerm_subnet" "DBSubnet" {
  address_prefixes     = ["10.0.1.0/24"]
  name                 = "DBSubnet"
  resource_group_name  = "kt-cn-edu-rg"
  virtual_network_name = "VNet1"
  depends_on = [
    azurerm_virtual_network.VNet1,
  ]
}
resource "azurerm_subnet_route_table_association" "DBSubnetAssoc" {
  route_table_id = "/subscriptions/0c3cf580-73d2-4b42-9db8-c3517e198afc/resourceGroups/kt-cn-edu-rg/providers/Microsoft.Network/routeTables/VNet1-route-table"
  subnet_id      = "/subscriptions/0c3cf580-73d2-4b42-9db8-c3517e198afc/resourceGroups/kt-cn-edu-rg/providers/Microsoft.Network/virtualNetworks/VNet1/subnets/DBSubnet"
  depends_on = [
    azurerm_route_table.VNet1-route-table,
    azurerm_subnet.DBSubnet,
  ]
}
resource "azurerm_subnet" "WasSubnetName" {
  address_prefixes     = ["10.0.2.0/24"]
  name                 = "WasSubnetName"
  resource_group_name  = "kt-cn-edu-rg"
  virtual_network_name = "VNet1"
  depends_on = [
    azurerm_virtual_network.VNet1,
  ]
}
resource "azurerm_subnet_route_table_association" "WasSubnetAssoc" {
  route_table_id = "/subscriptions/0c3cf580-73d2-4b42-9db8-c3517e198afc/resourceGroups/kt-cn-edu-rg/providers/Microsoft.Network/routeTables/VNet1-route-table"
  subnet_id      = "/subscriptions/0c3cf580-73d2-4b42-9db8-c3517e198afc/resourceGroups/kt-cn-edu-rg/providers/Microsoft.Network/virtualNetworks/VNet1/subnets/WasSubnetName"
  depends_on = [
    azurerm_route_table.VNet1-route-table,
    azurerm_subnet.WasSubnetName,
  ]
}