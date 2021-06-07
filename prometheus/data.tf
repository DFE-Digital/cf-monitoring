data "cloudfoundry_domain" "cloudapps" {
  name = "london.cloudapps.digital"
}

data "cloudfoundry_service_key" "prometheus_key" {
  name             = "prometheus-key"
  service_instance = var.influxdb_service_instance_id
}
