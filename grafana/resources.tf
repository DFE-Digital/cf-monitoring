resource "random_password" "admin_password" {
  length  = 30
  special = false
  lower   = true
  upper   = true
  number  = true
}

resource "cloudfoundry_route" "grafana" {
  domain   = data.cloudfoundry_domain.cloudapps.id
  space    = var.monitoring_space_id
  hostname = "grafana-${var.monitoring_instance_name}"
}

resource "cloudfoundry_app" "grafana" {
  name             = "grafana-${var.monitoring_instance_name}"
  space            = var.monitoring_space_id
  path             = data.archive_file.config.output_path
  source_code_hash = data.archive_file.config.output_base64sha256
  buildpack        = "https://github.com/SpringerPE/cf-grafana-buildpack"
  routes {
    route = cloudfoundry_route.grafana.id
  }
  environment = {
    ADMIN_PASS = random_password.admin_password.result
  }
}

resource "cloudfoundry_service_instance" "postgres" {
  count        = var.postgres_plan != "" ? 1 : 0
  name         = "grafana-${var.monitoring_instance_name}"
  space        = var.monitoring_space_id
  service_plan = data.cloudfoundry_service.postgres.service_plans[var.postgres_plan]
  tags         = []
}

resource "cloudfoundry_service_key" "grafana_key" {
  name             = "grafana-key"
  service_instance = cloudfoundry_service_instance.postgres[0].id
}
