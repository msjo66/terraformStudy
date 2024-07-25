module "ktRegionSelector" {
  source = "../modules/kt-regions"
  geography = var.geography
}

locals {
  location = module.ktRegionSelector.two_regions_with_zones[0].name
}

resource "azurerm_resource_group" "rg-terraform" {
  location = local.location
  name     = var.tf-state-info["rg-name"]
}

#terraform status 를 저장할 storage account및 blob container
resource "azurerm_storage_account" "st-terraform" {
    account_replication_type = var.tf-state-info["account-replication-type"]
    account_tier = var.tf-state-info["account-tier"]
    location = azurerm_resource_group.rg-terraform.location
    name = var.tf-state-info["account-name"]
    resource_group_name = azurerm_resource_group.rg-terraform.name
}
resource "azurerm_storage_container" "tfstate" {
    name = var.tf-state-info["container-name"]
    storage_account_name = azurerm_storage_account.st-terraform.name
    
}

# resource "azurerm_virtual_network" "vnet-az01-msjo66-tf" {
#   address_space       = ["10.0.0.0/16"]
#   location            = azurerm_resource_group.targetRG.location
#   name                = "vnet-az01-msjo66-tf"
#   resource_group_name = azurerm_resource_group.targetRG.name
#   depends_on = [
#     azurerm_resource_group.targetRG
#   ]
# }

# #bastion을 위한 subnet. bastion subnet에는 다른 nic, VM등을 만들 수 없다.
# resource "azurerm_subnet" "AzureBastionSubnet" {
#   address_prefixes     = ["10.0.0.0/27"]
#   name                 = "AzureBastionSubnet"
#   resource_group_name  = azurerm_resource_group.targetRG.name
#   virtual_network_name = azurerm_virtual_network.vnet-az01-msjo66-tf.name
#   depends_on = [
#     azurerm_virtual_network.vnet-az01-msjo66-tf,
#   ]
# }

# #vnet용 bastion 만들기(ip 포함)
# resource "azurerm_public_ip" "pip-bstn-az01-msjo66-tf-01" {
#     allocation_method = "Static"
#     location = azurerm_virtual_network.vnet-az01-msjo66-tf.location
#     name = "pip-bstn-az01-msjo66-tf-01"
#     resource_group_name = azurerm_resource_group.targetRG.name
#     sku = "Standard" # Bastion의 경우 Static만 되고, Standard라야 Static이 가능
# }
# resource "azurerm_bastion_host" "bstn-vnet-az01-msjo66-tf-01" {
#     location = azurerm_resource_group.targetRG.location
#     name = "bstn-vnet-az01-msjo66-tf-01"
#     resource_group_name = azurerm_resource_group.targetRG.name
#     ip_configuration {
#         name = "bstn-external"
#         public_ip_address_id = azurerm_public_ip.pip-bstn-az01-msjo66-tf-01.id
#         subnet_id = azurerm_subnet.AzureBastionSubnet.id
#     }
#     copy_paste_enabled = true 
#     file_copy_enabled = false # sku가 Standard 이상이어야 함
#     sku = "Basic"
    
# }

# #tf machine을 위한 subnet
# resource "azurerm_subnet" "sbn-az01-msjo66-tf-01" {
#   address_prefixes     = ["10.0.1.0/26"] #10.0.0.32/27은 왜 invalid CIDR block인가?
#   name                 = "sbn-az01-msjo66-tf-01"
#   resource_group_name  = azurerm_resource_group.targetRG.name
#   virtual_network_name = azurerm_virtual_network.vnet-az01-msjo66-tf.name
#   depends_on = [
#     azurerm_virtual_network.vnet-az01-msjo66-tf,
#   ]
# }
# #tf machine network card
# resource "azurerm_network_interface" "nic-vm-az01-msjo66-tf-01" {
#   location = azurerm_virtual_network.vnet-az01-msjo66-tf.location
#   name = "nic-vm-az01-msjo66-tf-01"
#   resource_group_name = azurerm_resource_group.targetRG.name
#   ip_configuration {
#     name = "internal"
#     subnet_id = azurerm_subnet.sbn-az01-msjo66-tf-01.id
#     private_ip_address_allocation = "Dynamic"
#   }
  
# }

# variable "adminId" {
#     sensitive = true
#     type=string
# }

# # tf machine을 만든다. 이 tf machine은 MSI(Managed System Identity)를 사용할 것이다.
# resource "azurerm_linux_virtual_machine" "vm-az01-msjo66-tf-01" {
#     location = azurerm_resource_group.targetRG.location
#     name = "vm-az01-msjo66-tf-01"
#     network_interface_ids = [ azurerm_network_interface.nic-vm-az01-msjo66-tf-01.id ]
#     resource_group_name =azurerm_resource_group.targetRG.name
#     size = "Standard_A1_v2"
#     admin_username = var.adminId
#     admin_ssh_key {
#         username   = var.adminId
#         public_key = file("~/.ssh/id_rsa.pub")
#     }
#     os_disk {
#         caching              = "ReadWrite"
#         storage_account_type = "Standard_LRS"
#     }
#     source_image_reference {
#         publisher = "Canonical"
#         offer     = "0001-com-ubuntu-server-jammy"
#         sku       = "22_04-lts"
#         version   = "latest"
#     }

#     identity {
#       type = "SystemAssigned"
#     }
# }

# data "azurerm_subscription" "current" {}

# data "azurerm_role_definition" "contributor" {
#     name = "Contributor"
# }

# resource "azurerm_role_assignment" "msi-to-tf" {
#     scope = data.azurerm_subscription.current.id
#     role_definition_id = "${data.azurerm_subscription.current.id}${data.azurerm_role_definition.contributor.id}"
#     principal_id = azurerm_linux_virtual_machine.vm-az01-msjo66-tf-01.identity[0].principal_id
# }
# tf machine 설정 끝

