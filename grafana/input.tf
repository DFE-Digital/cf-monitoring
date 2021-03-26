variable monitoring_instance_name {}

variable monitoring_space_id {}

variable prometheus_endpoint {}

variable runtime_version { default = "6.5.1" }

variable google_client_id { default = "" }
variable google_client_secret { default = "" }
variable google_jwt { default = "" }
variable influxdb_credentials { default = null}
variable elasticsearch_credentials {
  type = map

  default = {
    url      = ""
    username = ""
    password = ""
  }
}

variable admin_password {}
variable json_dashboards { default = [] }
variable extra_datasources { default = [] }

locals {
  dashboard_list = fileset(path.module, "dashboards/*.json")
  dashboards     = [for f in local.dashboard_list : file("${path.module}/${f}")]
  grafana_ini_variables = {
    google_client_id     = var.google_client_id
    google_client_secret = var.google_client_secret
  }
  grafana_datasource_variables = {
    google_jwt             = var.google_jwt
    elasticsearch_url      = var.elasticsearch_credentials.url
    elasticsearch_username = var.elasticsearch_credentials.username
    elasticsearch_password = var.elasticsearch_credentials.password
  }
  prometheus_datasource_variables = {
    prometheus_endpoint      = var.prometheus_endpoint
    monitoring_instance_name = var.monitoring_instance_name
    influxdb_hostname        = var.influxdb_credentials.hostname
    influxdb_port            = var.influxdb_credentials.port
    influxdb_username        = var.influxdb_credentials.username
    influxdb_password        = var.influxdb_credentials.password
  }
}
