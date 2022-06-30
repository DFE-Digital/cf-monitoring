variable "monitoring_instance_name" {}

variable "monitoring_space_id" {}

variable "prometheus_endpoint" {}
variable "prometheus_yearly_endpoint" { default = "" }

variable "runtime_version" { default = "" }

variable "google_client_id" { default = "" }
variable "google_client_secret" { default = "" }
variable "google_jwt" { default = "" }
variable "enable_anonymous_auth" { default = false }

variable "influxdb_credentials" { default = null }
variable "elasticsearch_credentials" {
  type = map(any)

  default = {
    url      = ""
    username = ""
    password = ""
  }
}

variable "admin_password" {}
variable "json_dashboards" { default = [] }
variable "extra_datasources" { default = [] }

locals {
  default_runtime_version = "7.5.12"
  dashboard_list          = fileset(path.module, "dashboards/*.json")
  dashboards              = [for f in local.dashboard_list : file("${path.module}/${f}")]
  grafana_ini_variables = {
    google_client_id      = var.google_client_id
    google_client_secret  = var.google_client_secret
    enable_anonymous_auth = var.enable_anonymous_auth
  }
  grafana_datasource_variables = {
    google_jwt             = var.google_jwt
    elasticsearch_url      = var.elasticsearch_credentials.url
    elasticsearch_username = var.elasticsearch_credentials.username
    elasticsearch_password = var.elasticsearch_credentials.password
  }
  prometheus_datasource_variables = {
    prometheus_endpoint        = var.prometheus_endpoint
    prometheus_yearly_endpoint = var.prometheus_yearly_endpoint
    monitoring_instance_name   = var.monitoring_instance_name
    influxdb_hostname          = var.influxdb_credentials.hostname
    influxdb_port              = var.influxdb_credentials.port
    influxdb_username          = var.influxdb_credentials.username
    influxdb_password          = var.influxdb_credentials.password
  }
  runtime_version   = var.runtime_version != "" ? var.runtime_version : local.default_runtime_version
  runtime_variables = { runtime_version = local.runtime_version }
}
