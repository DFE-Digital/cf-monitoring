# POSTGRES Exporter Module
This is a terraform module used to install the [POSTGRES-EXPORTER](https://github.com/prometheus-community/postgres_exporter)  application into the Government PaaS, and setting some of the configuration.


### Inputs
```monitoring_space_id           MANDATORY
   monitoring_instance_name      MANDATORY
   postgres_service_instance_id     MANDATORY
```

### Outputs
``` endpoint    URL of Postgres exporter endpoint, required by Prometheus
```

### Example Usage
```
module "postgres" {
     source = "git::https://github.com/DFE-Digital/bat-platform-building-blocks.git//terraform/modules/postgres_exporter?ref=master"

     monitoring_space_id                = data.cloudfoundry_space.space.id
     monitoring_instance_name           = "get_into_teaching"
     postgres_service_instance_id          = data.cloudfoundry_service_instance.postgres.id
}
```
