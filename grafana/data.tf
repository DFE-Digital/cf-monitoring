data "cloudfoundry_domain" "cloudapps" {
  name = "cloudapps.digital"
}

data "cloudfoundry_service" "postgres" {
  name = "postgres"
}
