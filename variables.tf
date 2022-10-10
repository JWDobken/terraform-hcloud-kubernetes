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
  type        = list(any)
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

# CONTROL-PLANE NODES
variable "control_plane_type" {
  description = "(Optional) - For more types have a look at https://www.hetzner.de/cloud"
  type        = string
  default     = "cx11"
}

variable "control_plane_count" {
  description = "(Optional) - Number of control-plane nodes."
  type        = number
  default     = 1
}

variable "image" {
  description = "(Optional) - Predefined Image that will be used to spin up the machines."
  type        = string
  default     = "ubuntu-20.04"
}

variable "control_plane_name_format" {
  description = "(Optional) - Format for the control-plane node names, defaults to 'control-plane-0'."
  type        = string
  default     = "control-plane-%d"
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

variable "workername_format" {
  description = "(Optional) - Format for the worker node names, defaults to 'worker-0'."
  type        = string
  default     = "worker-%d"
}

# KUBERNETES
variable "kubernetes_version" {
  description = "(Optional) - Kubernetes version installed, e.g. '1.25.2'."
  type        = string
  default     = "1.25.2"
}
