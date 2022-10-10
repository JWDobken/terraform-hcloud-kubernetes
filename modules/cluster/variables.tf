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
variable "network_zone" {
  type = string
}

variable "network_ip_range" {
  type = string
}

variable "subnet_ip_range" {
  type = string
}

# CONTROL-PLANE NODES
variable "control_plane_type" {
  type = string
}

variable "control_plane_count" {
  type = number
}

variable "control_plane_name_format" {
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
