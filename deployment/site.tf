terraform {
  backend "s3" {
    bucket  = "notify.tools-terraform-state"
    key     = "cf-prometheus-monitoring/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }

  required_providers {
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

variable "cloudfoundry_sso_passcode" {}

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
  internal_apps = [
    "notify-statsd-exporter-preview.apps.internal:8080"
  ]
}
