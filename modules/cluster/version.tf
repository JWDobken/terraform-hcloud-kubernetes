# cluster/version.tf
terraform {
  required_version = ">= 0.13"
  required_providers {
    hcloud = {
      source = "terraform-providers/hcloud"
    }
  }
}