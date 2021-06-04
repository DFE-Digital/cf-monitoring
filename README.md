# Cloud Foundry monitoring

Collection of [terraform](https://www.terraform.io/) modules to deploy the [prometheus](https://prometheus.io/) ecosystem to [Cloud foundry](https://www.cloudfoundry.org/).
Prometheus collects the metrics from Cloud foundry: applications, services, cpu, memory, etc. Metrics are then persisted to [InfluxDB](https://www.influxdata.com/products/influxdb-overview/).
Metrics-based alerts can be created in prometheus and processed by [alertmanager](https://prometheus.io/docs/alerting/) to send to Slack, email, pagerduty, etc.
Finally, the metrics are available in [grafana](https://grafana.com/) to build dashboards, help troubleshooting and create alerts. A default Cloud foundry dashboard is included.

## Prerequisites

- By default, the influxdb database service must be present (as it is on [GOV.UK PaaS](https://www.cloud.service.gov.uk/)). If not, another backend can be used and the influxdb module disabled.
- The [paas-prometheus-exporter](https://github.com/alphagov/paas-prometheus-exporter) requires a cf username and password to connect and read metrics. It is recommended to create a service account
and set it up as `SpaceAuditor` on each monitored space.
- [Terraform](https://www.terraform.io/) (Tested with version 0.14)
- [Terraform cloudfoundry provider](https://registry.terraform.io/providers/cloudfoundry-community/cloudfoundry/latest)

## Redis Services
If your application uses REDIS you may want to include a REDIS Metrics Exporter for each instance of REDIS you use. This is accomplished by passing in an array of strings. Each string takes the form
of Space/Service, for example

```
     redis_services = [ 'get_into_teaching/redis_service_one' , 'get_into_teaching/redis_service_two' , ... ]
```

## External exporters
List of external endpoints which can be queried via `/metrics`. Can be used for apps deployed to Cloud foundry or any external services.

They must be accessible via https.

## prometheus_all

Wrapper module abstracting all the other modules. It should be sufficient for most use cases but underlying modules can also be used directly.

## How to use

Example:

```hcl
module prometheus_all {
  source = "git::https://github.com/DFE-Digital/cf-monitoring.git//prometheus_all"

  monitoring_instance_name = "teaching-vacancies"
  monitoring_org_name      = "dfe"
  monitoring_space_name    = "teaching-vacancies-monitoring"
  paas_exporter_username   = var.paas_exporter_username
  paas_exporter_password   = var.paas_exporter_password
  alertmanager_config      = file("${path.module}/files/alertmanager.yml")
  grafana_admin_password   = var.grafana_admin_password
  grafana_json_dashboards  = [
    file("${path.module}/dashboards/frontend.json)",
    file("${path.module}/dashboards/backend.json)"
  ]
  external_exporters      = ["www.my-external-service.org"]
}
```

The git reference can be changed. For example for the `dev` branch:
```
source = "git::https://github.com/DFE-Digital/cf-monitoring.git//prometheus_all?ref=dev"
```
