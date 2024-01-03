terraform {

  // https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/tunnel

    required_version = ">= 0.13.0"

    required_providers {

      kubernetes = {
        source  = "hashicorp/kubernetes"
        version = ">= 1.11.3"
      }

      helm = {
        source = "hashicorp/helm"
        version = ">= 1.3.2"
      }

      cloudflare = {
        source = "cloudflare/cloudflare"
        version = ">= 2.0.0"
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
