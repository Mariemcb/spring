provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  
}

resource "azurerm_app_service_plan" "service-plan" {
  name                = "app-service-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_app_service" "app-service" {
  name                = "app-service"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.service-plan.id

  site_config {
    always_on = false
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    JAVA_VERSION = "1.8"
  }

 
}


resource "null_resource" "deploy_jar" {
  provisioner "local-exec" {
    command = "curl -X POST -F \"file=@${var.jar_file_path}\" https://${azurerm_app_service.app-service.default_site_hostname}/deploy"
  }
  depends_on = [azurerm_app_service.app-service]
}



