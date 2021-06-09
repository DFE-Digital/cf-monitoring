# PostreSQL exporter module
This is a terraform module used to install the [postgres_exporter](https://github.com/prometheus-community/postgres_exporter)  application into the Cloud Foundry, and setting some of the configuration.

### Inputs
```
    monitoring_space_id           MANDATORY
    monitoring_instance_name      MANDATORY
    postgres_service_instance     MANDATORY
```

postgres_service_instance format: `"space/service_name"`

ie space the service resides in and the name of the postgres service, separated by a `/`.

### Outputs
```
    endpoint    URL of Postgres exporter endpoint, required by Prometheus
```

### Example Usage
```
module "postgres" {
    source = "git::https://github.com/DFE-Digital/bat-platform-building-blocks.git//terraform/modules/postgres_exporter?ref=master"

    monitoring_space_id                = data.cloudfoundry_space.space.id
    monitoring_instance_name           = "get_into_teaching"
    postgres_service_instance          = "space/service_name"
}
```
