# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      #version = ">=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}



# Create a resource group
resource "azurerm_resource_group" "notifier_bot_rg" {
  name     = "rfc_bot_rg"
  location = var.resource_group_location
}

resource "azurerm_user_assigned_identity" "notifier_bot_uai" {
  location            = azurerm_resource_group.notifier_bot_rg.location
  name                = "${var.bot_name}_uai"
  resource_group_name = azurerm_resource_group.notifier_bot_rg.name
}

resource "azurerm_service_plan" "notifier_bot_sp" {
  name                = "${var.bot_name}_sp"
  resource_group_name = azurerm_resource_group.notifier_bot_rg.name
  location            = azurerm_resource_group.notifier_bot_rg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "notifier_bot_as" {
  name                = "${var.bot_name}-as"
  resource_group_name = azurerm_resource_group.notifier_bot_rg.name
  location            = azurerm_service_plan.notifier_bot_sp.location
  service_plan_id     = azurerm_service_plan.notifier_bot_sp.id

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.notifier_bot_uai.id]
  }

  https_only = true

  site_config {
    #acr_user_managed_identity_client_id = ...
    #app_command_line                    = ""
    application_stack {
      node_version = var.node_version
    }
    always_on         = false // Required for F1 plan (even though docs say that it defaults to false)
    use_32_bit_worker = true // Required for F1 plan
    app_command_line = "node ./lib/index.js"
  }

  cors {
    allowed_origins = ["https://portal.azure.com"]
  }

  zip_deploy_file   = var.zip_deploy_file
}

resource "azurerm_application_insights" "notifier-bot-appinsights" {
  name                = "${var.bot_name}-appinsights"
  location            = azurerm_resource_group.notifier_bot_rg.location
  resource_group_name = azurerm_resource_group.notifier_bot_rg.name
  application_type    = "web"
}

resource "azurerm_application_insights_api_key" "notifier_bot-appinsightsapikey" {
  name                    = "${var.bot_name}-appinsightsapikey"
  application_insights_id = azurerm_application_insights.notifier-bot-appinsights.id
  read_permissions        = ["aggregate", "api", "draft", "extendqueries", "search"]
}

data "azurerm_client_config" "current" {}

resource "azurerm_bot_service_azure_bot" "notifier_bot_bot" {
  name                = "${var.bot_name}_bot"
  resource_group_name = azurerm_resource_group.notifier_bot_rg.name
  location            = "global"
#  microsoft_app_id    = data.azurerm_client_config.current.client_id
  microsoft_app_id    = azurerm_user_assigned_identity.notifier_bot_uai.client_id
  sku                 = "F0"

  endpoint                              = "https://${var.bot_name}-as.azurewebsites.net/api/messages"
  developer_app_insights_api_key        = azurerm_application_insights_api_key.notifier_bot-appinsightsapikey.api_key
  developer_app_insights_application_id = azurerm_application_insights.notifier-bot-appinsights.app_id
}