resource "random_password" "cloudflare_tunnel_secret" {
  length = 64
}

# Creates a new locally-managed tunnel.
resource "cloudflare_tunnel" "auto_tunnel" {
  account_id = var.cloudflare_account_id
  name       = "cloudflare_tunnel"
  secret     = base64sha256(random_password.cloudflare_tunnel_secret.result)
}

# Creates the CNAME record that routes http_app.${var.cloudflare_zone} to the tunnel.
resource "cloudflare_record" "http_app" {
  zone_id = var.cloudflare_zone_id
  name    = "http_app"
  value   = "${cloudflare_tunnel.auto_tunnel.cname}"
  type    = "CNAME"
  proxied = true
}

# Creates the configuration for the tunnel.
resource "cloudflare_tunnel_config" "auto_tunnel" {
  tunnel_id = cloudflare_tunnel.auto_tunnel.id
  account_id = var.cloudflare_account_id
  config {
   ingress_rule {
     hostname = "${cloudflare_record.http_app.hostname}"
     service  = "http://httpbin:8080"
   }
   ingress_rule {
     service  = "http_status:404"
   }
  }
}

# Creates an Access application to control who can connect.
resource "cloudflare_access_application" "http_app" {
  zone_id          = var.cloudflare_zone_id
  name             = "Access application for http_app.${var.cloudflare_zone}"
  domain           = "http_app.${var.cloudflare_zone}"
  session_duration = "1h"
}

# Creates an Access policy for the application.
resource "cloudflare_access_policy" "http_policy" {
  application_id = cloudflare_access_application.http_app.id
  zone_id        = var.cloudflare_zone_id
  name           = "Example policy for http_app.${var.cloudflare_zone}"
  precedence     = "1"
  decision       = "allow"
  include {
    email = [var.cloudflare_email]
  }
}