# get cluster module output
output "network_id" {
  value       = module.cluster.network_id
  description = "Unique ID of the network."
}

output "private_ips" {
  value       = module.cluster.private_ips
  description = "The IPv4 addresses within the private network."
}

output "control_plane_nodes" {
  value       = module.cluster.control_plane_nodes
  description = "The control-plane node objects."
}

output "control_plane_nodes_ips" {
  value       = module.cluster.control_plane_nodes.*.ipv4_address
  description = "The IPv4 addresses within the control-plane network."
}

output "control_plane_nodes_ids" {
  value       = module.cluster.control_plane_nodes.*.id
  description = "The ids of the control-plane nodes."
}

output "worker_nodes" {
  value       = module.cluster.worker_nodes
  description = "The worker node objects."
}

output "worker_nodes_ips" {
  value       = module.cluster.worker_nodes.*.ipv4_address
  description = "The IPv4 addresses within the worker network."
}

output "worker_nodes_ids" {
  value       = module.cluster.worker_nodes.*.id
  description = "The ids of the worker nodes."
}

output "kubeconfig" {
  value       = module.kubernetes.kubeconfig
  description = "Kubectl config file contents for the cluster."
}

output "endpoint" {
  value       = module.kubernetes.endpoint
  description = "The endpoint for the Kubernetes API."
}

output "certificate_authority_data" {
  value       = module.kubernetes.certificate_authority_data
  description = "Nested attribute containing certificate-authority-data for the cluster. This is the base64 encoded certificate data required to communicate with the cluster."
}

output "client_certificate_data" {
  value       = module.kubernetes.client_certificate_data
  description = "Client certificate to communicate with the API."
}

output "client_key_data" {
  value       = module.kubernetes.client_key_data
  description = "Client key to communicate with the API."
}
