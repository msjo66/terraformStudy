resource "azurerm_resource_group" "kt-cn-edu-rg" {
  location = "koreacentral"
  name     = "kt-cn-edu-rg"
}
resource "azurerm_route_table" "VNet1-route-table" {
  location            = "koreacentral"
  name                = "VNet1-route-table"
  resource_group_name = "kt-cn-edu-rg"
  depends_on = [
    azurerm_resource_group.kt-cn-edu-rg,
  ]
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
resource "azurerm_subnet" "AzureBastionSubnet" {
  address_prefixes     = ["10.0.0.0/26"]
  name                 = "AzureBastionSubnet"
  resource_group_name  = "kt-cn-edu-rg"
  virtual_network_name = "VNet1"
  depends_on = [
    azurerm_virtual_network.VNet1,
  ]
}
# resource "azurerm_subnet" "DBSubnet" {
#   address_prefixes     = ["10.0.1.0/24"]
#   name                 = "DBSubnet"
#   resource_group_name  = "kt-cn-edu-rg"
#   virtual_network_name = "VNet1"
#   depends_on = [
#     azurerm_virtual_network.VNet1,
#   ]
# }
# resource "azurerm_subnet_route_table_association" "DBSubnetAssoc" {
#   route_table_id = "/subscriptions/0c3cf580-73d2-4b42-9db8-c3517e198afc/resourceGroups/kt-cn-edu-rg/providers/Microsoft.Network/routeTables/VNet1-route-table"
#   subnet_id      = "/subscriptions/0c3cf580-73d2-4b42-9db8-c3517e198afc/resourceGroups/kt-cn-edu-rg/providers/Microsoft.Network/virtualNetworks/VNet1/subnets/DBSubnet"
#   depends_on = [
#     azurerm_route_table.VNet1-route-table,
#     azurerm_subnet.DBSubnet,
#   ]
# }
# resource "azurerm_subnet" "WasSubnetName" {
#   address_prefixes     = ["10.0.2.0/24"]
#   name                 = "WasSubnetName"
#   resource_group_name  = "kt-cn-edu-rg"
#   virtual_network_name = "VNet1"
#   depends_on = [
#     azurerm_virtual_network.VNet1,
#   ]
# }
# resource "azurerm_subnet_route_table_association" "WasSubnetAssoc" {
#   route_table_id = "/subscriptions/0c3cf580-73d2-4b42-9db8-c3517e198afc/resourceGroups/kt-cn-edu-rg/providers/Microsoft.Network/routeTables/VNet1-route-table"
#   subnet_id      = "/subscriptions/0c3cf580-73d2-4b42-9db8-c3517e198afc/resourceGroups/kt-cn-edu-rg/providers/Microsoft.Network/virtualNetworks/VNet1/subnets/WasSubnetName"
#   depends_on = [
#     azurerm_route_table.VNet1-route-table,
#     azurerm_subnet.WasSubnetName,
#   ]
# }

# ## for cloud shell
# resource "azurerm_storage_account" "stcshell" {
#   account_replication_type = "GRS"
#   account_tier = "Standard"
#   location = azurerm_resource_group.kt-cn-edu-rg.location
#   name = "msjo66stcshell"
#   resource_group_name = azurerm_resource_group.kt-cn-edu-rg.name
# }
# resource "azurerm_storage_share" "cshell-share" {
#   name = "cshell-share"
#   quota = 50
#   storage_account_name = azurerm_storage_account.stcshell.name
# }
# resource "azurerm_network_profile" "netprofile_cshell" {
#   location = azurerm_resource_group.kt-cn-edu-rg.location
#   name = "netprofile_cshell"
#   resource_group_name = azurerm_resource_group.kt-cn-edu-rg.name
#   container_network_interface {
#     name = "cni-cshell"
#     ip_configuration {
#       name = "cshell-ip-conf"
#       subnet_id = azurerm_subnet.AzureBastionSubnet.id
#     }
#   }
# }
# resource "azurerm_relay_namespace" "relaynscshell" {
#   location = azurerm_resource_group.kt-cn-edu-rg.location
#   name = "relaynscshell"
#   resource_group_name = azurerm_resource_group.kt-cn-edu-rg.name
#   sku_name = "Standard"
# }
# ## end for cloud shell

# resource "azurerm_network_interface" "db1nic1" {
#   location = azurerm_resource_group.kt-cn-edu-rg.location
#   name = "db1nic1"
#   resource_group_name = azurerm_resource_group.kt-cn-edu-rg.name
#   ip_configuration {
#     name = "db1_nic1_ip"
#     subnet_id = azurerm_subnet.DBSubnet.id
#     private_ip_address_allocation = "Dynamic"
#   }  
# }

# variable "admin_password" {
#   type = string
#   sensitive = true
#   default = "changeItNow"
# }

# resource "azurerm_virtual_machine" "db1" {
#   location = azurerm_resource_group.kt-cn-edu-rg.location
#   name = "db1"
#   network_interface_ids = [ azurerm_network_interface.db1nic1.id ]
#   resource_group_name = azurerm_resource_group.kt-cn-edu-rg.name
#   vm_size = "Standard_A1_v2"
#   # Uncomment this line to delete the OS disk automatically when deleting the VM
#   delete_os_disk_on_termination = true

#   # Uncomment this line to delete the data disks automatically when deleting the VM
#   delete_data_disks_on_termination = true

#   storage_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "22_04-lts"
#     version   = "latest"
#   }
#   storage_os_disk {
#     name              = "myosdisk1"
#     caching           = "ReadWrite"
#     create_option     = "FromImage"
#     managed_disk_type = "Standard_LRS"
#   }
#   os_profile {
#     computer_name  = "db1"
#     admin_username = "db1admin"
#     admin_password = var.admin_password
#   }
#   os_profile_linux_config {
#     disable_password_authentication = false
#   }
#   tags = {
#     environment = "staging"
#   }
  
# }