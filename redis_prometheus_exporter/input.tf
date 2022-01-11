variable "org_name" { default = "dfe" }
variable "monitoring_space_id" {}
variable "redis_service_instance" {}
variable "docker_credentials" {
  description = "Credentials for Dockerhub. Map of {username, password}."
  type        = map(any)
  default = {
    username = ""
    password = ""
  }
}
locals {
  docker_image_tag = "v1.25.0-amd64"
}
