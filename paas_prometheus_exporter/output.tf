output "exporter" {
  value = {
    endpoint     = "${cloudfoundry_route.paas_prometheus_exporter.endpoint}:8080"
    name         = cloudfoundry_app.paas_prometheus_exporter.name
    scheme       = "http"
    honor_labels = true
  }
}

output "app_id" {
  value = cloudfoundry_app.paas_prometheus_exporter.id
}
