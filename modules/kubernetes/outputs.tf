# kubernetes/outputs.tf

output "connections" {
  value = local.connections
}

output "kubeconfig" {
  value = module.kubeconfig.stdout
}
