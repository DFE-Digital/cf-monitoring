terraform {
  backend "s3" {
    bucket  = "notify.tools-terraform-state"
    key     = "cf-prometheus-monitoring/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }

  required_providers {
    pass = {
      source = "mecodia/pass"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "4.6.0"
    }

    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = ">= 0.12.6"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

provider "cloudfoundry" {
  api_url             = "https://api.cloud.service.gov.uk"
  sso_passcode        = var.cloudfoundry_sso_passcode
  skip_ssl_validation = false
  app_logs_max        = 30
  store_tokens_path   = "./config.json"
}

data "pass_password" "basic_auth_password" {
  path = "credentials/http_auth/notify/password"
}

data "pass_password" "grafana_github_client_id" {
  path = "credentials/monitoring/grafana-github-oauth-client-id"
}

data "pass_password" "grafana_github_client_secret" {
  path = "credentials/monitoring/grafana-github-oauth-client-secret"
}

data "pass_password" "prometheus_shared_token" {
  path = "credentials/monitoring/prometheus-shared-token"
}

variable "cloudfoundry_sso_passcode" {}

locals {
  org_name = "govuk-notify"
  spaces = [
    "preview",
    "staging",
    "production",
  ]
  internal_apps_per_space = [
    "notify-statsd-exporter",
    "notify-api",
    "notify-admin",
  ]
  cross_space_apps = [
    "notify-prometheus-exporter.apps.internal"
  ]

  internal_apps = {
    for pair in setproduct(local.spaces, local.internal_apps_per_space) : "${pair[1]}-${pair[0]}.apps.internal" => {
      space    = pair[0]
      app_name = pair[1]
    }
  }
}

module "prometheus" {
  source = "../prometheus_all"
  enabled_modules = [
    "influxdb",
    "prometheus",
    "grafana",
    "paas_prometheus_exporter",
  ]

  monitoring_org_name      = local.org_name
  monitoring_space_name    = "monitoring"
  monitoring_instance_name = "notify"

  grafana_postgres_plan        = "small-11"
  grafana_github_client_id     = data.pass_password.grafana_github_client_id.password
  grafana_github_client_secret = data.pass_password.grafana_github_client_secret.password
  grafana_github_team_ids = [
    1789721 # notify
  ]

  influxdb_service_plan = "tiny-1_x"

  paas_exporter_username = ""
  paas_exporter_password = ""

  internal_apps = concat(local.cross_space_apps, keys(local.internal_apps))

  prometheus_basic_auth_password = data.pass_password.basic_auth_password.password
  prometheus_shared_token        = data.pass_password.prometheus_shared_token.password
}
