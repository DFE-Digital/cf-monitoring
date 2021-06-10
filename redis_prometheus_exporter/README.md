# Redis exporter module
This is a terraform module used to install the [redis_exporter](https://github.com/oliver006/redis_exporter) application into Cloud Foundry, and setting some of the configuration.

### Inputs
```
   monitoring_space_id           MANDATORY
   monitoring_instance_name      MANDATORY
   redis_service_instance        MANDATORY
```

redis_service_instance format: `"space/service_name"`

ie space the service resides in and the name of the redis service, separated by a `/`.


### Outputs
```
   endpoint    URL of Redis exporter endpoint, required by Prometheus
```

### Example Usage
```
module "redis" {
   source = "git::https://github.com/DFE-Digital/bat-platform-building-blocks.git//terraform/modules/redis_exporter?ref=master"

   monitoring_space_id                = data.cloudfoundry_space.space.id
   monitoring_instance_name           = "get_into_teaching"
   redis_service_instance             = "space/service_name"
}
```
