variable "monitoring_instance_name" {}
variable "monitoring_space_id" {}

variable "paas_username" {}
variable "paas_password" {}
variable "docker_credentials" {
  description = "Credentials for Dockerhub. Map of {username, password}."
  type        = map(any)
  default = {
    username = ""
    password = ""
  }
}
locals {
  docker_image_tag = "f161a7c90250053964eb179c936dc587ffafc2f3"
  paas_api_url     = "https://api.cloud.service.gov.uk"
  environment_variable_map = {
    API_ENDPOINT = local.paas_api_url
    USERNAME     = var.paas_username
    PASSWORD     = var.paas_password
  }
}
