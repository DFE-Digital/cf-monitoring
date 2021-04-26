data cloudfoundry_space redis_space {
  name     = split("/", var.redis_service_instance)[0]
  org_name = var.org_name
}

data cloudfoundry_service_instance redis_instance {
  name_or_id = split("/", var.redis_service_instance)[1]
  space      = data.cloudfoundry_space.redis_space.id
}

resource cloudfoundry_service_key redis-key {
  name             = data.cloudfoundry_service_instance.redis_instance.name
  service_instance = data.cloudfoundry_service_instance.redis_instance.id
}

locals {
  url = "rediss://${cloudfoundry_service_key.redis-key.credentials.host}:${cloudfoundry_service_key.redis-key.credentials.port}"
}

resource cloudfoundry_app redis-exporter {
  name         = "redis-exporter-${data.cloudfoundry_service_instance.redis_instance.name}"
  space        = var.monitoring_space_id
  docker_image = "oliver006/redis_exporter:latest"

  routes {
    route = cloudfoundry_route.redis_exporter.id
  }

  environment = {
    REDIS_ADDR     = local.url
    REDIS_PASSWORD = cloudfoundry_service_key.redis-key.credentials.password
  }
}

resource cloudfoundry_route redis_exporter {
  space    = var.monitoring_space_id
  domain   = data.cloudfoundry_domain.cloudapps.id
  hostname = data.cloudfoundry_service_instance.redis_instance.name
}

