## Grafana Module
This is a terraform module used to install the [grafana](https://grafana.com/) application into Cloud Foundry, and setting some of the configuration.

It is deployed using the [Springer grafana buildpack](https://github.com/SpringerPE/cf-grafana-buildpack).

Grafana can be integrated with github single sign on.  This has a number of advantages, the main being there is no need to locally manage users. It
provides readonly access by default, additional permissions are not persisted.

### Inputs
```
   monitoring_space_id       MANDATORY
   monitoring_instance_name  MANDATORY
   prometheus_endpoint       MANDATORY

   runtime_version           OPTIONAL
   github_client_id          OPTIONAL
   github_client_secret      OPTIONAL
   json_dashboards           OPTIONAL
   extra_datasources         OPTIONAL
```

### Datasources
The default prometheus datasource is already preconfigured.

Additional [data sources](https://grafana.com/docs/grafana/latest/datasources/) can be added via the `extra_datasources` input. It represents a list of datasources, each one being the string content of the yaml datasource file.

### Dashboards
Dashboards can be automatically loaded thanks to the `json_dashboards` variable. It represents a list of dashboards, each one being the string content of the json dashboard file, as exported by grafana.

### Plugins List
The following plugins are included. They are listed in the `plugins.txt` file:
```
grafana-piechart-panel
aidanmountford-html-panel
simpod-json-datasource
```
### Github Integration
Grafana supports integration with github logins. The ID must be configured and passed in to support this, following the [grafana instructions](https://grafana.com/docs/grafana/latest/auth/github/).

Step-by-step:
- Go to your org's settings and create an Oauth application: https://github.com/organizations/alphagov/settings/applications
- Set the callback url to be your grafana public url (e.g. https://grafana-notify.cloudapps.digital)

### Runtime version
The default version is 7. It has been tested successfully with version 6, 7 and 8.

### Example Usage
```
module "grafana" {
   source = "git::https://github.com/DFE-Digital/bat-platform-building-blocks.git//terraform/modules/grafana?ref=master"

   monitoring_space_id      = data.cloudfoundry_space.space.id
   monitoring_instance_name = "Graphana"
   json_dashboards          = [
      file("${path.module}/dashboards/frontend.json)",
      file("${path.module}/dashboards/backend.json)"
   ]
   prometheus_endpoint      = "https://prometheus.cloudapps.digital"
   runtime_version          = "x.x.x"
}
```
