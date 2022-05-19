## Alertmanager  Module
This is a terraform module used to install the [alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/) application into Cloud Foundry, and setting some of the configuration.

It is deployed using the official docker image.

### Inputs
```
  monitoring_space_id         MANDATORY
  monitoring_instance_name    MANDATORY
  config                      OPTIONAL
  slack_url                   OPTIONAL
  slack_channel               OPTIONAL
```

- **monitoring_instance_name:** A unique name given to the application
- **monitoring_space_id:** The Cloud Foundry space you wish to deploy the application to
- **config:**  The contents of an alertmanager.yml file, as specified in the [documentation](https://prometheus.io/docs/alerting/latest/configuration/). If not specified, a dummy configuration is deployed.

### Example
```hcl
module alertmanager {
  source                   = "git::https://github.com/DFE-Digital/bat-platform-building-blocks.git//terraform/modules/alertmanager"
  monitoring_space_id      = data.cloudfoundry_space.space.id
  monitoring_instance_name = "test-alertmanager"
  config                   = file("${path.module}/files/alertmanager.yml")
  slack_url                = https://hooks.slack.com/services/XXXXXXXXX/YYYYYYYYYYY/xxxxxxxxxxxxxxxxxxxxxxxx
  slack_channel            = mychannel
}
```

### Prometheus alerts

```yaml
- alert: TooManyRequests
  expr: 'sum(increase(tta_requests_total{path!~"csp_reports",status=~"429"}[1m])) > 0'
  labels:
    severity: high
  annotations:
    summary: Alert when any user hits a rate limit (excluding the /csp_reports endpoint).
    runbook: https://dfedigital.atlassian.net/wiki/spaces/GGIT/pages/2152497153/Rate+Limit
```
### Alert Routes
A route has been added which will ensure alerts are only sent to slack once every 24 hours. To implement this route you need to add the label ```period: daily```

```yaml
- alert: TooManyRequests
  expr: 'sum(increase(tta_requests_total{path!~"csp_reports",status=~"429"}[1m])) > 0'
  labels:
    severity: high
    period: daily
  annotations:
    summary: Alert when any user hits a rate limit (excluding the /csp_reports endpoint).
    runbook: https://dfedigital.atlassian.net/wiki/spaces/GGIT/pages/2152497153/Rate+Limit
```

### Testing Alertmanager

Install `amtool` with `go get github.com/prometheus/alertmanager/cmd/amtool` if testing locally. `amtool` is already installed in alertmanager paas instance.
1. Check if alertmanager is accessible

  `amtool --alertmanager.url=https://alertmanager-tra-monitoring-dev.london.cloudapps.digital config show`
  Above command displays alertmanager.yaml config.

2. Checking where alerts go

  `amtool --alertmanager.url=https://alertmanager-tra-monitoring-dev.london.cloudapps.digital config routes show`

	Routing tree:
   	└──	default-route  receiver: slack-notifications
			├── {period="daily"}  receiver: slack-notifications
			└── {period="'out-of-hours'"}  receiver: slack-notifications

3. ` amtool --alertmanager.url=https://alertmanager-tra-monitoring-dev.london.cloudapps.digital config routes test period=daily `
   prints `slack-notifications`

### Simulating an alert

Either `ssh` into alertmanager instance or run below command locally.

`amtool --alertmanager.url=https://alertmanager-tra-monitoring-dev.london.cloudapps.digital alert add this-is-a-test-alert period=hourly`

Above command will send a test alert to the SLACK_WEBHOOK.

### Templates
A default set of slack templates have been provided

### Acknowledgements to
https://gist.github.com/milesbxf/e2744fc90e9c41b47aa47925f8ff6512
