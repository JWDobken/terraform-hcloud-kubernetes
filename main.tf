# ./main.tf

# GENERAL
variable "cluster_name" {
  description = "(Required) - The name of the cluster."
  type        = string
}

variable "hcloud_token" {
  description = "(Required) - The Hetzner Cloud API Token, can also be specified with the HCLOUD_TOKEN environment variable."
  type        = string
}

variable "hcloud_ssh_keys" {
  description = "(Required) - SSH key IDs or names which should be injected into the server at creation time."
  type        = list
}

variable "location" {
  description = "(Optional) - Location, e.g. 'nbg1' (Neurenberg)."
  type        = string
  default     = "nbg1"
}

# NETWORK
variable "network_zone" {
  description = "(Optional) - Name of network zone, e.g. 'eu-central'."
  type        = string
  default     = "eu-central"
}

variable "network_ip_range" {
  description = "(Optional) - IP Range of the whole Network which must span all included subnets and route destinations. Must be one of the private ipv4 ranges of RFC1918."
  type        = string
  default     = "10.98.0.0/16"
}

variable "subnet_ip_range" {
  description = "(Optional) - Range to allocate IPs from. Must be a subnet of the ip_range of the Network and must not overlap with any other subnets or with any destinations in routes."
  type        = string
  default     = "10.98.0.0/16"
}

# MASTER NODES
variable "master_type" {
  description = "(Optional) - For more types have a look at https://www.hetzner.de/cloud"
  type        = string
  default     = "cx11"
}

variable "master_count" {
  description = "(Optional) - Number of master nodes."
  type        = number
  default     = 1
}

variable "image" {
  description = "(Optional) - Predefined Image that will be used to spin up the machines."
  type        = string
  default     = "ubuntu-20.04"
}

# WORKER NODES
variable "worker_type" {
  description = "(Optional) - For more types have a look at https://www.hetzner.de/cloud"
  type        = string
  default     = "cx21"
}

variable "worker_count" {
  description = "(Required) - Number of worker nodes."
  type        = number
}

# KUBERNETES
variable "kubernetes_version" {
  description = "(Optional) - Kubernetes version installed, e.g. '1.18.9'."
  type        = string
  default     = "1.18.9"
}

module "cluster" {
  source           = "./modules/cluster"
  hcloud_token     = var.hcloud_token
  hcloud_ssh_keys  = var.hcloud_ssh_keys
  cluster_name     = var.cluster_name
  location         = var.location
  image            = var.image
  network_zone     = var.network_zone
  network_ip_range = var.network_ip_range
  subnet_ip_range  = var.subnet_ip_range
  master_type      = var.master_type
  master_count     = var.master_count
  worker_type      = var.worker_type
  worker_count     = var.worker_count
}

module "firewall" {
  source          = "./modules/firewall"
  connections     = module.cluster.all_nodes.*.ipv4_address
  subnet_ip_range = var.subnet_ip_range
}

module "kubernetes" {
  source             = "./modules/kubernetes"
  hcloud_token       = var.hcloud_token
  network_id         = module.cluster.network_id
  cluster_name       = var.cluster_name
  master_nodes       = module.cluster.master_nodes
  worker_nodes       = module.cluster.worker_nodes
  private_ips        = module.cluster.private_ips
  kubernetes_version = var.kubernetes_version
}

# get cluster module output
output "network_id" {
  value = module.cluster.network_id
}

output "private_ips" {
  value = module.cluster.private_ips
}

output "kubernetes_cluster" {
  value = module.cluster.all_nodes.*.ipv4_address
}
