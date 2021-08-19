# providers
terraform {
  required_version = ">= 0.14.7"
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
}

variable "hcloud_token" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "master_type" {
  type = string
}

variable "worker_type" {
  type = string
}

variable "worker_count" {
  type = number
}

variable "load_balancer_name" {
  type = string
}

variable "load_balancer_type" {
  type = string
}

variable "load_balancer_location" {
  type = string
}

provider "hcloud" {
  token = var.hcloud_token
}

# Create a new SSH key
resource "hcloud_ssh_key" "demo_keys" {
  name       = "demo-key"
  public_key = file("~/.ssh/hcloud.pub")
}

# Create a kubernetes cluster
module "hcloud_kubernetes_cluster" {
  source          = "JWDobken/kubernetes/hcloud"
  version         = "v0.1.9"
  cluster_name    = var.cluster_name
  hcloud_token    = var.hcloud_token
  hcloud_ssh_keys = [hcloud_ssh_key.demo_keys.id]
  master_type     = var.master_type
  worker_type     = var.worker_type
  worker_count    = var.worker_count
}

resource "hcloud_load_balancer" "load_balancer" {
  name               = var.load_balancer_name
  load_balancer_type = var.load_balancer_type
  location           = var.load_balancer_location
}

resource "hcloud_load_balancer_network" "cluster_network" {
  load_balancer_id = hcloud_load_balancer.load_balancer.id
  network_id       = module.hcloud_kubernetes_cluster.network_id
}

output "load_balancer" {
  value = hcloud_load_balancer.load_balancer
}

output "kubeconfig" {
  value = module.hcloud_kubernetes_cluster.kubeconfig
}

output "hcloud_kubernetes_cluster" {
  value = module.hcloud_kubernetes_cluster
}
