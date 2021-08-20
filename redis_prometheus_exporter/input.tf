variable "org_name" { default = "dfe" }
variable "monitoring_space_id" {}
variable "redis_service_instance" {}

locals {
  docker_image_tag = "v1.25.0-amd64"
}
