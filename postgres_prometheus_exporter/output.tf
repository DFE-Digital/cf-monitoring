output "exporter" {
  value = {
    endpoint = cloudfoundry_route.postgres_exporter.endpoint
    name     = cloudfoundry_app.postgres-exporter.name
    scheme   = "https"
  }
}
