variable "monitoring_instance_name" {}

variable "monitoring_space_id" {}

variable "config" { default = "" }

variable "slack_url" { default = "" }
variable "slack_channel" { default = "" }
variable "slack_template" { default = "" }
variable "docker_credentials" {
  description = "Credentials for Dockerhub. Map of {username, password}."
  type        = map(any)
  default = {
    username = ""
    password = ""
  }
}
locals {
  docker_image_tag = "v0.22.2"
  alertmanager_variables = {
    slack_url     = var.slack_url
    slack_channel = var.slack_channel
  }
  config         = var.config == "" ? templatefile("${path.module}/config/alertmanager.yml.tmpl", local.alertmanager_variables) : var.config
  slack_template = var.slack_template == "" ? file("${path.module}/config/slack.tmpl") : var.slack_template
}
