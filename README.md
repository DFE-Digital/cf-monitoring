# Cloud Foundry monitoring

Collection of [terraform](https://www.terraform.io/) modules to deploy the [prometheus](https://prometheus.io/) ecosystem to [Cloud foundry](https://www.cloudfoundry.org/).

- Prometheus exporters are deployed as paas applications to provide prometheus metrics for paas applications and services, paas billing, redis, postgres...
- Prometheus collects the metrics: applications, services, cpu, memory, cost, etc
- Metrics are then persisted to [InfluxDB](https://www.influxdata.com/products/influxdb-overview/)
- Metrics-based alerts can be created in prometheus and processed by [alertmanager](https://prometheus.io/docs/alerting/) to send to Slack, email, pagerduty, etc
- Finally, the metrics are available in [grafana](https://grafana.com/) to build dashboards, help troubleshooting and create alerts.

The [prometheus_all module](#prometheus-all) is a good starting point as it includes all the other modules.

## Source

[github.com/DFE-Digital/cf-monitoring](https://github.com/DFE-Digital/cf-monitoring)

## Prerequisites

- By default, the influxdb database service must be present (as it is on [GOV.UK PaaS](https://www.cloud.service.gov.uk/)). If not, another backend can be used and the influxdb module disabled.
- The [paas-prometheus-exporter](https://github.com/alphagov/paas-prometheus-exporter) requires a cf username and password to connect and read metrics.
It is recommended to create a service account and set it up as `SpaceAuditor` on each monitored space as well as `BillingManager` on the whole organisation.
- [Terraform](https://www.terraform.io/) (Tested with version 0.14)
- [Terraform cloudfoundry provider](https://registry.terraform.io/providers/cloudfoundry-community/cloudfoundry/latest)

## prometheus_all

Wrapper module abstracting all the other modules. It should be sufficient for most use cases but underlying modules can also be used directly.

The prometheus all module will create two instances of the Prometheus application, by doing this we can prevent large queries from impacting the metric collection process.

### Scraper
The scraper version of the Prometheus application has the configuration required to collect metrics from their given locations and raise alerts sending them to the [alertmanager](alertmanager/README.md).

### Read Only
The ReadOnly version of the Prometheus application is used by [Grafana](grafana/README.md) as a data source.

## Minimal configuration

```hcl
module prometheus_all {
  source = "git::https://github.com/DFE-Digital/cf-monitoring.git//prometheus_all"

  monitoring_instance_name = "teaching-vacancies"
  monitoring_org_name      = "dfe"
  monitoring_space_name    = "teaching-vacancies-monitoring"
  paas_exporter_username   = var.paas_exporter_username
  paas_exporter_password   = var.paas_exporter_password
  grafana_admin_password   = var.grafana_admin_password
}
```

## Use a specific cf-monitoring version
The git reference can be changed. For example for the `dev` branch:
```
source = "git::https://github.com/DFE-Digital/cf-monitoring.git//prometheus_all?ref=dev"
```

## Enable specific modules
It is possible to include modules selectively to help onboarding to prometheus_all step-by-step. See the list of modules in
[enabled_modules](https://github.com/DFE-Digital/cf-monitoring/blob/master/prometheus_all/input.tf).

```hcl
module prometheus_all {
  source = "git::https://github.com/DFE-Digital/cf-monitoring.git//prometheus_all"
  enabled_modules          = ["prometheus", "influxdb"]
  monitoring_instance_name = "teaching-vacancies"
  monitoring_org_name      = "dfe"
  monitoring_space_name    = "teaching-vacancies-monitoring"
}
```

## Grafana

By default authentication is only via username/password for the admin account. Autentication via Google single-sign-on can be configured. It provides
readonly access to users by default. Additional permissions are not persisted.

It provides several datasources:
- prometheus: for Cloud Foundry metrics and any other prometheus exporter
- influxdb: for influxDB internal metrics as well as all the metrics above, using the influxDB query language
- elasticsearch (optional): to query elasticsearch, extract data and generate metrics

A number of Grafana dashboards are included and are usable out-of-the-box to monitor your apps and services. By default it shows all your resources,
then you can filter them via drop-down menus.

You can add your own dashboards via the `grafana_json_dashboards` parameter.

See [Grafana README](grafana/README.md)

## PostgreSQL
Basic metrics are available in the `CF databases` dashboard. The `PostgreSQL advanced` dashboard provides more advanced metrics via the `postgres_prometheus_exporter` module.

See [postgres_prometheus_exporter README](postgres_prometheus_exporter/README.md)

## Redis Services
If your application uses Redis you may want to include a Redis metrics exporter for each instance of Redis you use. This is accomplished by passing in an array of strings. Each string takes the form
of `"space/service"`, for example:

```
redis_services = [ "get_into_teaching/redis_service_one" , "get_into_teaching/redis_service_two" , ... ]
```

## External exporters
List of external endpoints which can be queried via `/metrics`. Can be used for apps deployed to Cloud foundry or any external services.

They must be accessible via https.

## Internal apps
Pass a list of applications deployed to Cloud Foundry and prometheus will find each individual instance and scrape metrics from them. The format is:

```
["<app1_name>.<internal_domain>[:port]", "<app2_name>.<internal_domain>[:port]"]
```

If the port is not specified, the default Cloud Foundry port will be used (8080).

[Internal routing](https://docs.cloudfoundry.org/devguide/deploy-apps/routes-domains.html#internal-routes) must be configured so that prometheus can access them.
`prometheus_all` outputs both prometheus app name and id to help create the network policy.

**Note:** To allow useful aggregation and optimise time series storage, the applications should decorate the metrics with a label called `app_instance`
representing the id of the Cloud Foundry app instance. It can be obtained at runtime from the `CF_INSTANCE_INDEX` environment variable.

## alertmanager
A default configuration is provided but it doesn't send any notification. You can configure slack to publish to a webhook or provide your own configuration.

See [alertmanager README](alertmanager/README.md)

## Dockerhub pull rate limit

Deploying apps that depends on Dockerhub image pull can result in failure because of error **You have reached your pull rate limit** if not authenticated to Dockerhub.

Dockerhub credentials can be passed into the modules as follows:

```
docker_credentials = {

  username = ""
  password = ""
}
