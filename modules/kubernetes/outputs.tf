# kubernetes/outputs.tf

output "connections" {
  value = local.connections
}

output "kubeconfig" {
  value = module.kubeconfig.stdout
}

output "endpoint" {
  value = module.endpoint.stdout
}

output "certificate_authority_data" {
  value = module.certificate_authority_data.stdout
}

output "client_certificate_data" {
  value = module.client_certificate_data.stdout
}

output "client_key_data" {
  value = module.client_key_data.stdout
}
