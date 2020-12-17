# cluster/variables.tf

# GENERAL
variable "hcloud_token" {
  default = ""
}

variable "hcloud_ssh_keys" {
  type = list(any)
}

variable "cluster_name" {
  type = string
}

variable "location" {
  type = string
}

variable "image" {
  type = string
}

# NETWORK
variable "create_network" {
  type = bool
}

variable "network_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "network_zone" {
  type = string
}

variable "network_ip_range" {
  type = string
}

variable "subnet_ip_range" {
  type = string
}

# MASTER NODES
variable "master_type" {
  type = string
}

variable "master_count" {
  type = number
}

# WORKER NODES
variable "worker_type" {
  type = string
}

variable "worker_count" {
  type = number
}

# LOAD BALANCER
variable "loadbalancer_ip" {
  type    = string
  default = "159.69.0.1"
}
