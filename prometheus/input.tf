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
  template_variable_map = {
    exporters             = var.exporters
    alertmanager_endpoint = var.alertmanager_endpoint
    include_alerting      = var.alert_rules != ""
    include_scrapes       = var.extra_scrape_config != ""
    scrapes               = var.extra_scrape_config
  }

  config_file = templatefile("${path.module}/templates/prometheus.yml.tmpl", local.template_variable_map)
}
