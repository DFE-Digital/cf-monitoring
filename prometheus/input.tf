variable "monitoring_space_id" {}

variable "monitoring_instance_name" {}

# Each exporter in the list is a map with format:
# {   name: "unique_name_in_prometheus",
#     scheme: "https or http", (optional, default: http)
#     endpoint: "Endpoint domain where /metrics can be queried",
#     honor_labels: true/false (optional, default: false)
# }
# See: https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config
variable "exporters" { default = [] }

variable "alertmanager_endpoint" { default = "" }

variable "memory" { default = 1024 }

variable "disk_quota" { default = 1024 }

variable "influxdb_service_instance_id" {}

variable "alert_rules" { default = "" }

variable "extra_scrape_config" { default = "" }

locals {
  app_name = "prometheus-${var.monitoring_instance_name}"
  exporters = [for exporter in var.exporters :
    {
      endpoint     = exporter.endpoint
      name         = exporter.name
      scheme       = contains(keys(exporter), "scheme") ? exporter.scheme : "https"
      honor_labels = contains(keys(exporter), "honor_labels") ? exporter.honor_labels : false
    }
  ]
  template_variable_map = {
    exporters             = local.exporters
    alertmanager_endpoint = var.alertmanager_endpoint
    include_alerting      = var.alert_rules != ""
    include_scrapes       = var.extra_scrape_config != ""
    scrapes               = var.extra_scrape_config
    remote_read_url       = data.cloudfoundry_service_key.prometheus_key.credentials.prometheus_remote_read_0_url
    remote_write_url      = data.cloudfoundry_service_key.prometheus_key.credentials.prometheus_remote_write_0_url
    remote_read_recent    = data.cloudfoundry_service_key.prometheus_key.credentials.prometheus_remote_read_0_read_recent
    remote_write_username = data.cloudfoundry_service_key.prometheus_key.credentials.prometheus_remote_write_0_basic_auth_username
    remote_write_password = data.cloudfoundry_service_key.prometheus_key.credentials.prometheus_remote_write_0_basic_auth_password
    remote_read_username  = data.cloudfoundry_service_key.prometheus_key.credentials.prometheus_remote_read_0_basic_auth_username
    remote_read_password  = data.cloudfoundry_service_key.prometheus_key.credentials.prometheus_remote_read_0_basic_auth_password
  }
  config_file = templatefile("${path.module}/templates/prometheus.yml.tmpl", local.template_variable_map)
}
