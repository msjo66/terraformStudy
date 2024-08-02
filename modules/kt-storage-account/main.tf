
locals {
    rg-name = var.base-info.rg_name
    rg-location = var.base-info.location
    subscription_id = var.base-info.subscription_id
    stgacct-name = var.stgacct-info.name
}

resource "azurerm_private_dns_zone" "pdns-stgacct" {
  name                = var.pdns-stgacct-info.name
  resource_group_name = var.base-info.rg_name
}

resource "azurerm_private_dns_a_record" "a-pdns-stgacct" {
  name                = var.a-pdns-stgacct-info.name
  records             = [azurerm_private_endpoint.pe-stgacct.private_service_connection[0].private_ip_address]
  resource_group_name = var.base-info.rg_name
  ttl                 = var.a-pdns-stgacct-info.ttl
  zone_name           = var.a-pdns-stgacct-info.zone_name
  depends_on = [
    azurerm_private_dns_zone.pdns-stgacct,
    azurerm_private_endpoint.pe-stgacct
  ]
}
resource "azurerm_private_dns_zone_virtual_network_link" "pdns-vnetlink-stgacct" {
  name                  = var.pdns-vnetlink-stgacct-info.name
  private_dns_zone_name = var.pdns-vnetlink-stgacct-info.private_dns_zone_name
  resource_group_name   = var.base-info.rg_name
  virtual_network_id    = "/subscriptions/${var.base-info.subscription_id}/resourceGroups/${var.base-info.rg_name}/providers/Microsoft.Network/virtualNetworks/${var.base-info.vnet_name}"
  depends_on = [
    azurerm_private_dns_zone.pdns-stgacct,
  ]
}
resource "azurerm_private_endpoint" "pe-stgacct" {
  location            = var.base-info.location
  resource_group_name = var.base-info.rg_name
  name                = var.pe-stgacct-info.name
  subnet_id           = "/subscriptions/${var.base-info.subscription_id}/resourceGroups/${var.base-info.rg_name}/providers/Microsoft.Network/virtualNetworks/${var.base-info.vnet_name}/subnets/${var.pe-stgacct-info.subnet_name}"
  private_service_connection {
    is_manual_connection           = false
    name                           = var.pe-stgacct-info.conn_name
    private_connection_resource_id = "/subscriptions/${var.base-info.subscription_id}/resourceGroups/${var.base-info.rg_name}/providers/Microsoft.Storage/storageAccounts/${var.stgacct-info.name}"
    subresource_names              = var.pe-stgacct-info.conn_subresource_names
  }
  depends_on = [
    azurerm_storage_account.stgacct
  ]
}
resource "azurerm_storage_account" "stgacct" {
  account_replication_type         = var.stgacct-info.account_replication_type
  account_tier                     = var.stgacct-info.account_tier
  allow_nested_items_to_be_public  = var.stgacct-info.allow_nested_items_to_be_public
  cross_tenant_replication_enabled = var.stgacct-info.cross_tenant_replication_enabled
  enable_https_traffic_only        = var.stgacct-info.enable_https_traffic_only
  location                         = local.rg-location
  name                             = var.stgacct-info.name
  public_network_access_enabled    = var.stgacct-info.public_network_access_enabled
  resource_group_name              = local.rg-name
}
