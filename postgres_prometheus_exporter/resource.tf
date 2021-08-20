data "cloudfoundry_space" "postgres_space" {
  name     = split("/", var.postgres_service_instance)[0]
  org_name = var.org_name
}

data "cloudfoundry_service_instance" "postgres_instance" {
  name_or_id = split("/", var.postgres_service_instance)[1]
  space      = data.cloudfoundry_space.postgres_space.id
}

resource "cloudfoundry_service_key" "postgres-key" {
  name             = data.cloudfoundry_service_instance.postgres_instance.name
  service_instance = data.cloudfoundry_service_instance.postgres_instance.id
}

resource "cloudfoundry_app" "postgres-exporter" {
  name         = "postgres-exporter-${data.cloudfoundry_service_instance.postgres_instance.name}"
  space        = var.monitoring_space_id
  docker_image = "quay.io/prometheuscommunity/postgres-exporter:${local.docker_image_tag}"

  routes {
    route = cloudfoundry_route.postgres_exporter.id
  }

  environment = {
    DATA_SOURCE_NAME = cloudfoundry_service_key.postgres-key.credentials.uri
  }
}

resource "cloudfoundry_route" "postgres_exporter" {
  space    = var.monitoring_space_id
  domain   = data.cloudfoundry_domain.cloudapps.id
  hostname = data.cloudfoundry_service_instance.postgres_instance.name
}
