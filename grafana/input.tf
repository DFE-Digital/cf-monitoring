variable "monitoring_instance_name" {}

variable "monitoring_space_id" {}

variable "prometheus_endpoint" {}
variable "prometheus_yearly_endpoint" { default = "" }

variable "runtime_version" { default = "" }

variable "github_client_id" {}
variable "github_client_secret" {}
variable "github_team_ids" { type = list(number) }
variable "influxdb_credentials" { default = null }
variable "json_dashboards" { default = [] }
variable "extra_datasources" { default = [] }
variable "postgres_plan" { default = "" }
variable "basic_auth_password" { default = "" }
variable "basic_auth_username" { default = "notify" }
variable "aws_datasources" { 
  type = list(object({
    "name"                   = string
    "region"                 = string
    "access_key"             = string
    "secret_key"             = string
    "customMetricNamespaces" = string
  }))
  sensitive = true
}

locals {
  default_runtime_version = "8.3.1"
  dashboard_list          = fileset(path.module, "dashboards/*.json")
  dashboards              = [for f in local.dashboard_list : file("${path.module}/${f}")]
  grafana_ini_variables = {
    root_url             = "https://${cloudfoundry_route.grafana.endpoint}"
    github_client_id     = var.github_client_id
    github_client_secret = var.github_client_secret
    github_team_ids      = join(",", var.github_team_ids)
    database_url         = cloudfoundry_service_key.grafana_key.credentials.uri

  }
  prometheus_datasource_variables = {
    prometheus_endpoint        = var.prometheus_endpoint
    prometheus_yearly_endpoint = var.prometheus_yearly_endpoint
    monitoring_instance_name   = var.monitoring_instance_name
    influxdb_hostname          = var.influxdb_credentials.hostname
    influxdb_port              = var.influxdb_credentials.port
    influxdb_username          = var.influxdb_credentials.username
    influxdb_password          = var.influxdb_credentials.password
    basic_auth_username        = var.basic_auth_username
    basic_auth_password        = var.basic_auth_password
  }
  runtime_version   = var.runtime_version != "" ? var.runtime_version : local.default_runtime_version
  runtime_variables = { runtime_version = local.runtime_version }
}
