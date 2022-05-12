resource "cloudfoundry_route" "prometheus" {
  domain   = data.cloudfoundry_domain.cloudapps.id
  space    = var.monitoring_space_id
  hostname = "prometheus-${var.monitoring_instance_name}"
}

resource "cloudfoundry_app" "prometheus" {
  name               = local.app_name
  space              = var.monitoring_space_id
  memory             = local.memory
  disk_quota         = local.disk_quota
  command            = "echo \"$${PROM_CONFIG}\" > /etc/prometheus/prometheus.yml; echo \"$${ALERT_RULES}\" > /etc/prometheus/alert.rules; echo \"$${POSTGRES_ALERT_RULES}\" > /etc/prometheus/postgres.alert.rules; echo \"$${APP_ALERT_RULES}\" > /etc/prometheus/app.alert.rules;  ${local.command}"
  docker_image       = "prom/prometheus:${local.docker_image_tag}"
  docker_credentials = var.docker_credentials
  environment = {
    PROM_CONFIG          = local.config_file
    ALERT_RULES          = var.alert_rules
    POSTGRES_ALERT_RULES = local.postgres_alert_rules
    APP_ALERT_RULES      = local.app_alert_rules
  }

  service_binding {
    service_instance = var.influxdb_service_instance_id
  }
  routes {
    route = cloudfoundry_route.prometheus.id
  }
}
