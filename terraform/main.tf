provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    Owner = var.owner
    Script = "Custom Terraform Script"
  }
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

  tags = {
    Owner = var.owner
    Script = "Custom Terraform Script"
  }
}

output "app_service_url" {
  value = azurerm_app_service.app-service.default_site_hostname
}



pipeline {
  agent any

  stages {
    stage('Build') {
      steps {
        script {
          sh "mvn clean package"
        }
      }
    }

    stage('Upload to Azure Storage') {
      steps {
        script {
          sh "az storage blob upload --account-name ${storageAccountName} --container-name ${storageContainerName} --name hello-world.jar --file ${jarFile} --auth-mode login"
        }
      }
    }

    stage('Initialize Terraform') {
      steps {
        script {
          runTerraform('init')
        }
      }
    }

    stage('Plan Terraform') {
      steps {
        script {
          runTerraform('plan')
        }
      }
    }

    stage('Apply Terraform') {
      steps {
        script {
          runTerraform('apply -auto-approve')
        }
      }
    }
  }

  post {
    always {
      echo 'Pipeline complete.'
    }
  }
}