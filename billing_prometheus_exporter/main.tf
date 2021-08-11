resource "cloudfoundry_route" "billing_exporter" {
  domain   = data.cloudfoundry_domain.cloudapps.id
  space    = var.monitoring_space_id
  hostname = "billing-exporter-${var.monitoring_instance_name}"
}

resource "cloudfoundry_app" "billing_exporter" {
  name         = "billing-exporter-${var.monitoring_instance_name}"
  space        = var.monitoring_space_id
  memory       = "256"
  disk_quota   = "512"
  docker_image = "ghcr.io/dfe-digital/paas-billing-exporter:main"
  environment = {
    PAAS_USERNAME = var.paas_username
    PAAS_PASSWORD = var.paas_password
  }

  routes {
    route = cloudfoundry_route.billing_exporter.id
  }
}
