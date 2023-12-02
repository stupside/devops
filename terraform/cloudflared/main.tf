terraform {

  required_providers {

    cloudflare = {
      version = "4.22.0"

      source = "cloudflare/cloudflare"
    }

    random = {
      version = "3.6.0"
    }
  }
}
