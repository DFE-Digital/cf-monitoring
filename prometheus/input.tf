variable "monitoring_space_id" {}

variable "monitoring_instance_name" {}

# Each exporter in the list is a map with format:
# {   name: "unique_name_in_prometheus",
#     scheme: "https or http", (optional, default: http)
#     endpoint: "Endpoint domain where /metrics can be queried",
#     honor_labels: true/false (optional, default: false)
#     scrape_interval: "time in s,m,h..." (default: use local.default_scrape_interval)
# }
# See: https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config
variable "exporters" { default = [] }

variable "alertmanager_endpoint" { default = "" }

variable "memory" { default = "" }

variable "disk_quota" { default = "" }

variable "influxdb_service_instance_id" {}

variable "alert_rules" { default = "" }
variable "postgres_dashboard_url" { default = "" }
variable "alertable_postgres_services" { default = {} }
variable "alertable_apps" { default = {} }
variable "apps_dashboard_url" { default = "" }
variable "internal_apps" { default = [] }

variable "readonly" { default = false }
variable "yearly" { default = false }

variable "docker_credentials" {
  description = "Credentials for Dockerhub. Map of {username, password}."
  type        = map(any)
  default = {
    username = ""
    password = ""
  }
}

locals {
  docker_image_tag        = "v2.31.1"
  default_memory          = 1024
  memory                  = var.memory != "" ? var.memory : local.default_memory
  default_disk_quota      = 1024
  disk_quota              = var.disk_quota != "" ? var.disk_quota : local.default_disk_quota
  app_name                = "prometheus-${var.monitoring_instance_name}"
  default_scrape_interval = "15s"
  exporters = [for exporter in var.exporters :
    {
      endpoint        = exporter.endpoint
      name            = exporter.name
      scheme          = contains(keys(exporter), "scheme") ? exporter.scheme : "https"
      honor_labels    = contains(keys(exporter), "honor_labels") ? exporter.honor_labels : false
      scrape_interval = contains(keys(exporter), "scrape_interval") ? exporter.scrape_interval : local.default_scrape_interval
    }
  ]
  default_internal_app_port = "8080"
  internal_app_maps = [for app in var.internal_apps :
    {
      host = split(":", app)[0]
      port = try(split(":", app)[1], local.default_internal_app_port)
    }
  ]
  yearly_param = var.yearly == true ? "&rp=one_year" : ""
  template_variable_map = {
    exporters               = local.exporters
    alertmanager_endpoint   = var.alertmanager_endpoint
    include_alerting        = var.alert_rules != "" || var.alertable_postgres_services != {} || var.alertable_apps != {}
    remote_read_url         = data.cloudfoundry_service_key.prometheus_key.credentials.prometheus_remote_read_0_url
    remote_write_url        = data.cloudfoundry_service_key.prometheus_key.credentials.prometheus_remote_write_0_url
    remote_read_recent      = data.cloudfoundry_service_key.prometheus_key.credentials.prometheus_remote_read_0_read_recent
    remote_write_username   = data.cloudfoundry_service_key.prometheus_key.credentials.prometheus_remote_write_0_basic_auth_username
    remote_write_password   = data.cloudfoundry_service_key.prometheus_key.credentials.prometheus_remote_write_0_basic_auth_password
    remote_read_username    = data.cloudfoundry_service_key.prometheus_key.credentials.prometheus_remote_read_0_basic_auth_username
    remote_read_password    = data.cloudfoundry_service_key.prometheus_key.credentials.prometheus_remote_read_0_basic_auth_password
    internal_app_maps       = local.internal_app_maps
    default_scrape_interval = local.default_scrape_interval
    yearly_param            = local.yearly_param
  }
  config_file = templatefile(var.readonly == true ? "${path.module}/templates/readonly.yml.tmpl" : "${path.module}/templates/prometheus.yml.tmpl", local.template_variable_map)

  postgres_alert_rules_variables = {
    postgres_dashboard_url       = var.postgres_dashboard_url
    alertable_postgres_instances = local.internal_pg_map
  }

  app_alert_rules_variables = {
    cfapps_dashboard_url = var.apps_dashboard_url
    apps                 = local.app_map
  }

  app_map = [for instance, settings in var.alertable_apps : {
    app_name                       = instance
    max_cpu                        = try(settings.max_cpu, 50)
    max_mem                        = try(settings.max_mem, 60)
    max_disk                       = try(settings.max_disk, 60)
    max_crash_count                = try(settings.max_crash_count, 1)
    max_elevated_req_failure_count = try(settings.max_elevated_req_failure_count, 0.1)
    response_threshold             = try(settings.response_threshold, 1)
    }
  ]

  internal_pg_map = [for instance, settings in var.alertable_postgres_services : {
    pg_fullname  = instance
    pg_spacename = split("/", instance)[0]
    pg_instance  = split("/", instance)[1]
    max_cpu      = try(settings.max_cpu, 60)
    min_mem      = try(settings.min_mem, 0.5)
    min_stg      = try(settings.min_stg, 1)
    }
  ]

  app_alert_rules      = length(var.alertable_apps) == 0 ? "" : templatefile("${path.module}/templates/app_alert.rules.tmpl", local.app_alert_rules_variables)
  postgres_alert_rules = length(var.alertable_postgres_services) == 0 ? "" : templatefile("${path.module}/templates/pg_alert.rules.tmpl", local.postgres_alert_rules_variables)

  # From https://github.com/prometheus/prometheus/blob/main/Dockerfile
  default_command_list = [
    "/bin/prometheus",
    "--storage.tsdb.path=/prometheus",
    "--config.file=/etc/prometheus/prometheus.yml",
    "--web.console.libraries=/usr/share/prometheus/console_libraries",
    "--web.console.templates=/usr/share/prometheus/consoles"
  ]
  extra_command_list = [
    "--storage.tsdb.retention.time 12h",
    "--storage.tsdb.retention.size 1GB"
  ]
  command = join(" ", concat(local.default_command_list, local.extra_command_list))
}
