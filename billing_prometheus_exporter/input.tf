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
  docker_image_tag = "v0.0.3"
}
