output "exporter" {
  value = {
    endpoint        = cloudfoundry_route.billing_exporter.endpoint
    name            = cloudfoundry_app.billing_exporter.name
    scrape_interval = "1h"
  }
}
