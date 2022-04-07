data "archive_file" "config" {
  type        = "zip"
  output_path = "${path.module}/files/grafana.zip"

  source {
    content  = file("${path.module}/config/plugins.txt")
    filename = "plugins.txt"
  }


  source {
    content  = templatefile("${path.module}/config/runtime.txt", local.runtime_variables)
    filename = "runtime.txt"
  }

  source {
    content  = templatefile("${path.module}/config/grafana.ini", merge(local.grafana_ini_variables, cloudfoundry_service_key.grafana_key.credentials))
    filename = "grafana.ini"
  }

  source {
    content  = file("${path.module}/files/dashboard_provider.yml")
    filename = "dashboards/dashboard_provider.yml"
  }

  source {
    content  = templatefile("${path.module}/datasources/prometheus.yml.tmpl", local.prometheus_datasource_variables)
    filename = "datasources/prometheus.yml"
  }

  source {
    content  = templatefile("${path.module}/datasources/prometheus_yearly.yml.tmpl", local.prometheus_datasource_variables)
    filename = "datasources/prometheus_yearly.yml"
  }

  source {
    content  = templatefile("${path.module}/datasources/influxdb.yml.tmpl", local.prometheus_datasource_variables)
    filename = "datasources/influxdb.yml"
  }

  dynamic "source" {
    for_each = local.dashboards
    content {
      content  = source.value
      filename = "dashboards/local_${source.key}.json"
    }
  }

  dynamic "source" {
    for_each = var.extra_datasources
    content {
      content  = source.value
      filename = "datasources/${source.key}.yml"
    }
  }

  dynamic "source" {
    for_each = var.json_dashboards
    content {
      content  = source.value
      filename = "dashboards/${source.key}.json"
    }
  }

}
