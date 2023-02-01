output "app_service_url" {
  value = azurerm_bot_service_azure_bot.notifier_bot_bot.endpoint
}

output "tennant_id" {
  value = azurerm_user_assigned_identity.notifier_bot_uai.tenant_id
}

output "microsoft_app_id" {
  value = azurerm_user_assigned_identity.notifier_bot_uai.client_id
}