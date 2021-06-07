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
  command      = "echo \"$${PROM_CONFIG}\" > /etc/prometheus/prometheus.yml; echo \"$${ALERT_RULES}\" > /etc/prometheus/alert.rules; /bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/prometheus --web.console.libraries=/usr/share/prometheus/console_libraries --web.console.templates=/usr/share/prometheus/consoles"
  docker_image = "prom/prometheus:v2.27.1"
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
