variable "bot_name" {
  default     = "notifier-bot"
  description = "Name for the chat bot"
}

variable "resource_group_name" {
  default     = "notifier-bot-rg"
  description = "Azure Resource Group Name"
}

variable "resource_group_location" {
  default     = "West Europe"
  description = "Azure Resource Group Name"
}

variable "create_resourse_group" {
  default     = true
  type        = bool
  description = "Whether to create a new resource group. For existing group set this to 0 and provide resource_group_name and resource_group_location variables"
}

variable "node_version" {
  default     = "14-lts"
  description = "Node.js version used to run the bot"
}