## Grafana Module
This is a terraform module used to install the [grafana](https://grafana.com/) application into Cloud Foundry, and setting some of the configuration.

It is deployed using the [Springer grafana buildpack](https://github.com/SpringerPE/cf-grafana-buildpack).

Grafana can be integrated with google single sign on.  This has a number of advantages, the main being there is no need to locally manage users. It
provides readonly access by default, additional permissions are not persisted.

### Inputs
```
   monitoring_space_id       MANDATORY
   monitoring_instance_name  MANDATORY
   prometheus_endpoint       MANDATORY
   admin_password            MANDATORY

   runtime_version           OPTIONAL
   google_client_id          OPTIONAL
   google_client_secret      OPTIONAL
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
grafana-googlesheets-datasource
```
### LOGIT (ELK) Integration
By passing in the URL, Username and Password of an ELK stack end point, such as [Logit]( logit.io ) the deployment will include a datasource which you can use in dashboards to incorporate log data.
The ELK datasource does not need to be added as it is a default datasorce.

### Google Integration
Grafana supports integration with google logins. The ID must be configured and passed in to support this, following the [grafana instructions](https://grafana.com/docs/grafana/latest/auth/google/).
It is also possible to include data from Google Sheets if a GOOGLE_JWT string is passed.

Ste-by-step:
- Navigate to the Google API Console
- Navigate to the Credentials Screen
- At the top of the screen click on the  link and choose OAuth Client ID from the pop-up list
- Enter **APPLICATION TYPE** as **WEB APPLICATION**
- Enter **NAME**, put in a unique name that identifies your project.
- Under the **AUTHORISED JAVASCRIPT AUTHORISATION**  field enter a list of URLs that your code uses. In our case we entered
   - https://grafana-dev-get-into-teaching.london.cloudapps.digital
   - https://grafana-prod-get-into-teaching.london.cloudapps.digital
- Under the **AUTHORISED REDIRECT URIS**  field enter a list of feedback URLs, these are provided by Grafana, but in our case we used
   - http://grafana-dev-get-into-teaching.london.cloudapps.digital/login/google
   - http://grafana-dev-get-into-teaching.london.cloudapps.digital/login/google

That should be enough to configure Google.  You will be given a client_id and a client_secret which you will need to use in Grafana. These two fields can be read again if you return to the screen.

### Runtime version
The default version is 7. It has been tested successfully with version 6, 7 and 8.

### Example Usage
```
module "grafana" {
   source = "git::https://github.com/DFE-Digital/bat-platform-building-blocks.git//terraform/modules/grafana?ref=master"

   monitoring_space_id      = data.cloudfoundry_space.space.id
   monitoring_instance_name = "Graphana"
   admin_password           = "xxxxx"
   json_dashboards          = [
      file("${path.module}/dashboards/frontend.json)",
      file("${path.module}/dashboards/backend.json)"
   ]
   extra_datasources        = [file("${path.module}/datasources/elasticsearch.yml)",
   prometheus_endpoint      = "https://prometheus.london.cloudapps.digital"
   runtime_version          = "x.x.x"

   google_jwt               = "very long and secret JWT String"

   elasticsearch_credentials= {
      url = xxxx
      username = yyyyy
      password = zzzzz
   }
}
```
