variable "monitoring_instance_name" {}
variable "monitoring_space_id" {}
variable "paas_username" {}
variable "paas_password" {}

locals {
  docker_image_tag = "v0.0.2"
}
