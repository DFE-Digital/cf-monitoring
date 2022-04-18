data "cloudfoundry_org" "notify" {
  name = local.org_name
}

data "cloudfoundry_space" "preview" {
  name = "preview"
  org  = data.cloudfoundry_org.notify.id
}

data "cloudfoundry_space" "staging" {
  name = "staging"
  org  = data.cloudfoundry_org.notify.id
}

data "cloudfoundry_space" "production" {
  name = "production"
  org  = data.cloudfoundry_org.notify.id
}

data "cloudfoundry_app" "preview" {
  count      = length(local.internal_apps_per_space)
  name_or_id = element(local.internal_apps_per_space, count.index)
  space      = data.cloudfoundry_space.preview.id
}

data "cloudfoundry_app" "staging" {
  count      = length(local.internal_apps_per_space)
  name_or_id = element(local.internal_apps_per_space, count.index)
  space      = data.cloudfoundry_space.staging.id
}

data "cloudfoundry_app" "production" {
  count      = length(local.internal_apps_per_space)
  name_or_id = element(local.internal_apps_per_space, count.index)
  space      = data.cloudfoundry_space.production.id
}

resource "cloudfoundry_network_policy" "preview" {
  count = length(local.internal_apps_per_space)

  policy {
    source_app      = module.prometheus.prometheus_app_id
    destination_app = element(data.cloudfoundry_app.preview.*.id, count.index)
    port            = "8080"
  }
}

resource "cloudfoundry_network_policy" "staging" {
  count = length(local.internal_apps_per_space)

  policy {
    source_app      = module.prometheus.prometheus_app_id
    destination_app = element(data.cloudfoundry_app.staging.*.id, count.index)
    port            = "8080"
  }
}

resource "cloudfoundry_network_policy" "production" {
  count = length(local.internal_apps_per_space)

  policy {
    source_app      = module.prometheus.prometheus_app_id
    destination_app = element(data.cloudfoundry_app.production.*.id, count.index)
    port            = "8080"
  }
}
