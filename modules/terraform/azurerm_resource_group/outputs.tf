output "id" {
  description = "The id of the resource group provisioned"
  value       = azurerm_resource_group.resource_group.id
}
output "name" {
  description = "The name of the resource group provisioned"
  value       = azurerm_resource_group.resource_group.name
}
output "location" {
  description = "The location of the resource group provisioned"
  value       = azurerm_resource_group.resource_group.location
}