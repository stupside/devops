terraform {

  required_version = ">= 0.14.0"

  cloud {
    organization = "xonery"

    workspaces {
      name = "devbox"
    }
  }
}
