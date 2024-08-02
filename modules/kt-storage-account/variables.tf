variable base-info {
    type = map(string)

    default = {
      rg_name = ""
      location = ""
      subscription_id = ""
      vnet_name = ""
    }
}

variable "stgacct-info" {
    type = object({
      name = string
      account_replication_type = string
      account_tier = string
      allow_nested_items_to_be_public = bool
      cross_tenant_replication_enabled = bool
      enable_https_traffic_only = bool
      public_network_access_enabled = bool 
    })

    default = {
      account_replication_type = "LRS"
      account_tier = "Standard"
      allow_nested_items_to_be_public = false
      cross_tenant_replication_enabled = false
      enable_https_traffic_only = false
      name = ""
      public_network_access_enabled = false
    }
}


variable "pe-stgacct-info" {
    type = object({
      name = string
      subnet_name = string
      conn_is_manual_connection = bool
      conn_name = string
      conn_subresource_names = list(string)
    })

    default = {
      conn_is_manual_connection = false
      conn_name = ""
      conn_subresource_names = [ "blob" ]
      name = ""
      subnet_name = ""
    }
}

variable "pdns-stgacct-info" {
    type = map(string)
    default = {
      "name" = ""
    }
}

variable "a-pdns-stgacct-info" {
    type = object({
      name = string
      ttl = number
      zone_name = string
    })

    default = {
      name = ""
      ttl = 3600
      zone_name = "privatelink.blob.core.windows.net"
    }
}

variable "pdns-vnetlink-stgacct-info" {
    type = map(string)

    default = {
      name = ""
      private_dns_zone_name = ""
      virtual_network_id = ""
    }
}