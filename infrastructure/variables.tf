variable "resource_group_location" {
  default = "West Europe"
}

variable "node_version" {
  default = "14-lts"
}

variable "zip_deploy_file" {
  default = "../notifier-bot.zip"
}

variable "bot_name" {
  default = "notifier-bot"
}