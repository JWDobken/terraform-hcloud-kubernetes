# cluster/version.tf
terraform {
  required_version = ">= 1.1.9"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.35.2"
    }
  }
}
