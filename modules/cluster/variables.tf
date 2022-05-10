# cluster/variables.tf

# GENERAL
variable "hcloud_token" {
  default = ""
}

variable "hcloud_ssh_private_key" {
  type = string
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

variable "mastername_format" {
  type = string
}

# WORKER NODES
variable "worker_type" {
  type = string
}

variable "worker_count" {
  type = number
}

variable "workername_format" {
  type = string
}

# LOAD BALANCER
variable "loadbalancer_ip" {
  type    = string
  default = "159.69.0.1"
}
