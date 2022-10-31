# kubernetes/variables.tf

# GENERAL
variable "hcloud_token" {
  default = ""
}

# NETWORK
variable "network_id" {
  type = string
}

variable "private_ips" {
  type = list(any)
}

# CONTROL-PLANE NODES
variable "control_plane_nodes" {
  type = list(any)
}

# WORKER NODES
variable "worker_nodes" {
  type = list(any)
}

# KUBERNETES
variable "kubernetes_version" {
  type = string
}

variable "cluster_name" {
  type = string
}
