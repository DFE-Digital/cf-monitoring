module "paas_prometheus_exporter" {
  source = "../paas_prometheus_exporter"
  count  = contains(var.enabled_modules, "paas_prometheus_exporter") ? 1 : 0

  monitoring_instance_name = var.monitoring_instance_name
  monitoring_space_id      = data.cloudfoundry_space.monitoring.id
  paas_username            = var.paas_exporter_username
  paas_password            = var.paas_exporter_password
  docker_credentials       = var.docker_credentials
}

module "redis_prometheus_exporter" {
  source                 = "../redis_prometheus_exporter"
  for_each               = toset(var.redis_services)
  monitoring_space_id    = data.cloudfoundry_space.monitoring.id
  redis_service_instance = each.key
  docker_credentials     = var.docker_credentials
}

module "postgres_prometheus_exporter" {
  source                    = "../postgres_prometheus_exporter"
  for_each                  = toset(var.postgres_services)
  monitoring_space_id       = data.cloudfoundry_space.monitoring.id
  postgres_service_instance = each.key
}

module "billing_prometheus_exporter" {
  count                    = contains(var.enabled_modules, "billing_prometheus_exporter") ? 1 : 0
  source                   = "../billing_prometheus_exporter"
  monitoring_instance_name = var.monitoring_instance_name
  monitoring_space_id      = data.cloudfoundry_space.monitoring.id
  paas_username            = var.paas_exporter_username
  paas_password            = var.paas_exporter_password
  docker_credentials       = var.docker_credentials
}

module "influxdb" {
  source = "../influxdb"
  count  = contains(var.enabled_modules, "influxdb") ? 1 : 0

  monitoring_instance_name = var.monitoring_instance_name
  monitoring_space_id      = data.cloudfoundry_space.monitoring.id
  service_plan             = var.influxdb_service_plan
}

module "prometheus_readonly" {
  source = "../prometheus"
  count  = contains(var.enabled_modules, "prometheus") ? 1 : 0

  monitoring_instance_name     = "readonly-${var.monitoring_instance_name}"
  monitoring_space_id          = data.cloudfoundry_space.monitoring.id
  influxdb_service_instance_id = module.influxdb[0].service_instance_id
  memory                       = var.prometheus_memory
  disk_quota                   = var.prometheus_disk_quota
  readonly                     = true
  docker_credentials           = var.docker_credentials
}

module "prometheus_yearly" {
  source = "../prometheus"
  count  = var.enable_prometheus_yearly ? 1 : 0

  monitoring_instance_name     = "yearly-${var.monitoring_instance_name}"
  monitoring_space_id          = data.cloudfoundry_space.monitoring.id
  influxdb_service_instance_id = module.influxdb[0].service_instance_id
  memory                       = var.prometheus_memory
  disk_quota                   = var.prometheus_disk_quota
  readonly                     = true
  yearly                       = true
  docker_credentials           = var.docker_credentials
}

module "prometheus" {
  source = "../prometheus"
  count  = contains(var.enabled_modules, "prometheus") ? 1 : 0

  monitoring_instance_name = var.monitoring_instance_name
  monitoring_space_id      = data.cloudfoundry_space.monitoring.id
  exporters = concat(
    local.list_of_redis_exporters,
    module.paas_prometheus_exporter.*.exporter,
    local.list_of_postgres_exporters,
    local.list_of_external_exporters,
    module.billing_prometheus_exporter.*.exporter
  )
  influxdb_service_instance_id = module.influxdb[0].service_instance_id
  alertmanager_endpoint        = contains(var.enabled_modules, "alertmanager") ? module.alertmanager[0].endpoint : ""
  alert_rules                  = var.alert_rules
  alertable_postgres_services  = var.alertable_postgres_services
  postgres_dashboard_url       = "${var.postgres_dashboard_url}/cf-databases?orgId=1&refresh=1m"
  alertable_apps               = var.alertable_apps
  apps_dashboard_url           = "${var.apps_dashboard_url}/cf-apps?orgId=1&refresh=1m"
  memory                       = var.prometheus_memory
  disk_quota                   = var.prometheus_disk_quota
  internal_apps                = var.internal_apps
  docker_credentials           = var.docker_credentials
}

module "alertmanager" {
  source = "../alertmanager"
  count  = contains(var.enabled_modules, "alertmanager") ? 1 : 0

  monitoring_instance_name = var.monitoring_instance_name
  monitoring_space_id      = data.cloudfoundry_space.monitoring.id
  config                   = var.alertmanager_config
  slack_url                = var.alertmanager_slack_url
  slack_receivers          = var.alertmanager_slack_receivers
  slack_template           = var.alertmanager_slack_template
  docker_credentials       = var.docker_credentials
}

module "grafana" {
  source = "../grafana"
  count  = contains(var.enabled_modules, "grafana") ? 1 : 0

  monitoring_instance_name   = var.monitoring_instance_name
  monitoring_space_id        = data.cloudfoundry_space.monitoring.id
  prometheus_endpoint        = module.prometheus_readonly[0].endpoint
  prometheus_yearly_endpoint = local.prometheus_yearly_endpoint
  google_client_id           = var.grafana_google_client_id
  google_client_secret       = var.grafana_google_client_secret
  google_jwt                 = var.grafana_google_jwt
  admin_password             = var.grafana_admin_password
  json_dashboards            = var.grafana_json_dashboards
  extra_datasources          = var.grafana_extra_datasources
  influxdb_credentials       = module.influxdb[0].credentials
  runtime_version            = var.grafana_runtime_version
  elasticsearch_credentials  = var.grafana_elasticsearch_credentials
  enable_anonymous_auth      = var.grafana_anonymous_auth
}
