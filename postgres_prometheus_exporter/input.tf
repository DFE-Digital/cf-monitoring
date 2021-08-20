variable "org_name" { default = "dfe" }
variable "monitoring_space_id" {}
variable "postgres_service_instance" {}

locals {
  docker_image_tag = "v0.10.0"
}
