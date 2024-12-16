# main.tf

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "tpterraform-rg" {
  name     = var.resource_group_name
  location = var.location
  
}

resource "azurerm_app_service_plan" "tpterraform-serviceplan" {
  name                = "tpterraformserviceplan"
  location            = azurerm_resource_group.tpterraform-rg.location
  resource_group_name = azurerm_resource_group.tpterraform-rg.name
  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_app_service" "tpterraform-appservice" {
  name                = "tpterraformappservice"
  location            = azurerm_resource_group.tpterraform-rg.location
  resource_group_name = azurerm_resource_group.tpterraform-rg.name
  app_service_plan_id = azurerm_app_service_plan.tpterraform-serviceplan.id

  site_config {
    always_on = false
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    JAVA_VERSION = "1.8"
  }

  tags = {
    Owner = var.owner
    Script = "Custom Terraform Script"
  }
}

resource "azurerm_storage_account" "tpterraform-storageaccount" {
  name                     = "examplestoracc${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.tpterraform-rg.name
  location                 = azurerm_resource_group.tpterraform-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Owner = var.owner
    Script = "Custom Terraform Script"
  }
}

resource "random_string" "suffix" {
  length  = 6
  special = false
}

resource "azurerm_storage_blob" "tpterraform-storgeblob" {
  name                   = "hello-world.jar"
  storage_account_name   = azurerm_storage_account.tpterraform-storageaccount.name
  storage_container_name = azurerm_storage_account.tpterraform-storageaccount.primary_blob_container
  type                   = "Block"
  source                 = var.jar_file_path

  depends_on = [
    azurerm_storage_account.tpterraform-storageaccount
  ]
}

resource "azurerm_storage_container" "tpterraform-storagecontainer" {
  name                  = "example-container"
  storage_account_name  = azurerm_storage_account.tpterraform-storageaccount.name
  container_access_type = "private"
}

output "app_service_url" {
  value = azurerm_app_service.tpterraform-appservice.default_site_hostname
}