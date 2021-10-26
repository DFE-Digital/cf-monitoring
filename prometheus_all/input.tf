variable "monitoring_instance_name" {
  description = "Name used as suffix on all created resources to identify the deployment uniquely"
}
variable "monitoring_org_name" {
  description = "Cloud foundry organisation where the monitoring solution is deployed"
}
variable "monitoring_space_name" {
  description = "Cloud foundry space where the monitoring solution is deployed"
}

variable "paas_exporter_username" {
  description = "Readonly cloud foundry user to query cloud foundry metrics. It must have BillingManager org role and SpaceAuditor space role on all the monitored spaces."
  default     = ""
}
variable "paas_exporter_password" {
  description = "Readonly cloud foundry user password"
  default     = ""
  sensitive   = true
}

variable "alertmanager_config" {
  description = "Alert manager configuration file (https://prometheus.io/docs/alerting/latest/configuration/). Passed as a long string."
  default     = ""
}
variable "alertmanager_slack_url" {
  description = "Slack webhook URL for alert notifications"
  default     = ""
}
variable "alertmanager_slack_channel" {
  description = "Slack channel for alert notifications"
  default     = ""
}
variable "alertmanager_slack_tempate" {
  description = "Slack message template for alert notifications"
  default     = ""
}
variable "alert_rules" {
  description = "Prometheus alert rules file (https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/). Passed as a long string."
  default     = ""
}

variable "grafana_google_client_id" {
  description = "Google client id for Grafana Google single-sign-on"
  default     = ""
}
variable "grafana_google_client_secret" {
  description = "Google client secret for Grafana Google single-sign-on"
  default     = ""
}
variable "grafana_admin_password" {
  description = "Grafana administrator password (User: admin)"
}
variable "grafana_json_dashboards" {
  description = <<-DESCRIPTION
  Additional Grafana dashboards. Passed as a list of long json strings.
  The dashboard can be exported as json from Grafana UI: https://grafana.com/docs/grafana/latest/dashboards/export-import/"
  DESCRIPTION
  default     = []
}
variable "grafana_extra_datasources" {
  description = <<-DESCRIPTION
  Additional Grafana data sources. Passed as a list of long yaml strings.
  See https://grafana.com/docs/grafana/latest/administration/provisioning/#data-sources
  DESCRIPTION
  default     = []
}
variable "grafana_google_jwt" {
  description = "Google JWT token for Grafana Google sheet data source"
  default     = ""
}
variable "grafana_runtime_version" {
  description = "Override default Grafana version. See Grafana module for current default version."
  default     = ""
}

variable "grafana_elasticsearch_credentials" {
  description = "Credentials for Grafana Elasticserach datasource. Map of {url, username, password}."
  type        = map(any)

  default = {
    url      = ""
    username = ""
    password = ""
  }
}

variable "prometheus_memory" {
  description = "Override default prometheus application allocated memory. See Prometheus module for current default value."
  default     = ""
}
variable "prometheus_disk_quota" {
  description = "Override default prometheus application allocated disk space. See Prometheus module for current default value."
  default     = ""
}

variable "influxdb_service_plan" {
  description = "Influxdb PaaS service plan. Run 'cf marketplace' to see available plans."
  default     = "tiny-1_x"
}

variable "redis_services" {
  description = "List of redis services for advanced monitoring and dashboard. [\"space1/redis1\", \"space2/redis2\", ...]"
  default     = []
}
variable "postgres_services" {
  description = "List of postrgres services for advanced monitoring and dashboard. [\"space1/postgres1\", \"space2/postgres2\", ...]"
  default     = []
}

variable "external_exporters" {
  description = "List of extra Prometheus exporter domains. Prometheus will scrape each domain via https at /metrics path."
  default     = []
}
variable "internal_apps" {
  description = "List internal PaaS applications providing metrics. Prometheus will scrape each app instance at '/metrics' path"
  default     = []
}

variable "enabled_modules" {
  description = "List of prometheus_all modules. Add them one by one to make onboarding easier."
  type        = list(any)
  default = [
    "paas_prometheus_exporter",
    "prometheus",
    "grafana",
    "alertmanager",
    "influxdb",
    "billing_prometheus_exporter"
  ]
}

locals {
  list_of_redis_exporters    = [for redis_module in module.redis_prometheus_exporter : redis_module.exporter]
  list_of_postgres_exporters = [for postgres_module in module.postgres_prometheus_exporter : postgres_module.exporter]
  list_of_external_exporters = [for endpoint in var.external_exporters :
    {
      endpoint = endpoint
      name     = endpoint
      scheme   = "https"
    }
  ]
}
