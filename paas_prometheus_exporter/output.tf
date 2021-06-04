output "exporter" {
  value = {
    endpoint = cloudfoundry_route.paas_prometheus_exporter.endpoint
    name     = cloudfoundry_app.paas_prometheus_exporter.name
    scheme   = "https"
  }
}

