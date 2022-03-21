terraform {
  required_providers {
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = ">= 0.12.6"
    }
  }
}

variable "cloudfoundry_sso_passcode" {}

provider "cloudfoundry" {
  api_url             = "https://api.cloud.service.gov.uk"
  sso_passcode        = var.cloudfoundry_sso_passcode
  skip_ssl_validation = false
  app_logs_max        = 30
  store_tokens_path   = "./config.json"
}

module "prometheus" {
  source = "../prometheus_all"
  enabled_modules = [
    "influxdb",
    "prometheus",
  ]

  monitoring_org_name      = "govuk-notify"
  monitoring_space_name    = "sandbox"
  monitoring_instance_name = "notify"

  influxdb_service_plan = "tiny-1_x"
}
