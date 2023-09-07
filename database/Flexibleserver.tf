#create database in your azure virtual machine
resource "azurerm_subnet" "default" {
  address_prefixes     = ["10.0.2.0/24"]
  name                 = "subnet-abhi"
  resource_group_name  = "IAC-rg"
  virtual_network_name = "IAC-vnet"
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "fs"

    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}
# Enables you to manage Private DNS zones within Azure DNS
resource "azurerm_private_dns_zone" "default" {
  name                = "abhiiac.mysql.database.azure.com"
  resource_group_name = "IAC-rg"
}

# Enables you to manage Private DNS zone Virtual Network Links
resource "azurerm_private_dns_zone_virtual_network_link" "default" {
  name                  = "mysqlfsVnetZoneAbhiIAC.com"
  private_dns_zone_name = "abhiiac.mysql.database.azure.com"
  resource_group_name   = "IAC-rg"
  #you should change your subscrption id, you will find it in your azure resource jason file
  virtual_network_id    = "/subscriptions/ef15c9b4-32ec-4aa4-a097-7e2cd9492e2c/resourceGroups/IAC-rg/providers/Microsoft.Network/virtualNetworks/IAC-vnet"
  depends_on = [azurerm_private_dns_zone.default]
}

resource "azurerm_mysql_flexible_database" "default" {
  name                = "mysqlfs-abhishekiac9998"
  resource_group_name = "IAC-rg"
  server_name         = azurerm_mysql_flexible_server.default.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
  depends_on = [ azurerm_mysql_flexible_server.default ]
}


# Manages the MySQL Flexible Server, sometimes we need to change server name
resource "azurerm_mysql_flexible_server" "default" {
  location                     = "AustraliaEast"
  name                         = "mysqlfs-abhishekiac9998"
  resource_group_name          = "IAC-rg"
  administrator_login          = "azureuser"
  administrator_password       = "Aspire2International@91"
  backup_retention_days        = 7
  delegated_subnet_id          = azurerm_subnet.default.id
  geo_redundant_backup_enabled = false
  private_dns_zone_id          = azurerm_private_dns_zone.default.id
  sku_name                     = "GP_Standard_D2ds_v4"
  version                      = "8.0.21"
  zone                         = "1"

  high_availability {
    mode                      = "ZoneRedundant"
    standby_availability_zone = "2"
  }
  maintenance_window {
    day_of_week  = 0
    start_hour   = 8
    start_minute = 0
  }
  storage {
    iops    = 360
    size_gb = 20
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.default]
}
