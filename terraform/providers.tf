terraform {

  // https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/tunnel

    required_version = ">= 0.13.0"

    required_providers {

      kubernetes = {
        source  = "hashicorp/kubernetes"
        version = ">= 2.24.0"
      }

      helm = {
        source = "hashicorp/helm"
        version = ">= 2.12.1"
      }

      cloudflare = {
        source = "cloudflare/cloudflare"
        version = "=> 4.0"
      }

      random = {
        source = "hashicorp/random"
      }
    }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "cloudflare" {
  api_token    = var.cloudflare_token
}
