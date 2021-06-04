output "exporter" {
  value = {
    endpoint = cloudfoundry_route.redis_exporter.endpoint
    name     = cloudfoundry_app.redis-exporter.name
    scheme   = "https"
  }
}
