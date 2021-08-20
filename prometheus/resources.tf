resource "cloudfoundry_route" "prometheus" {
  domain   = data.cloudfoundry_domain.cloudapps.id
  space    = var.monitoring_space_id
  hostname = "prometheus-${var.monitoring_instance_name}"
}

resource "cloudfoundry_app" "prometheus" {
  name         = local.app_name
  space        = var.monitoring_space_id
  memory       = var.memory
  disk_quota   = var.disk_quota
  command      = "echo \"$${PROM_CONFIG}\" > /etc/prometheus/prometheus.yml; echo \"$${ALERT_RULES}\" > /etc/prometheus/alert.rules; ${local.default_command} --storage.tsdb.retention.time 1h"
  docker_image = "prom/prometheus:${local.docker_image_tag}"
  environment = {
    PROM_CONFIG = local.config_file
    ALERT_RULES = var.alert_rules
  }

  service_binding {
    service_instance = var.influxdb_service_instance_id
  }
  routes {
    route = cloudfoundry_route.prometheus.id
  }
}
