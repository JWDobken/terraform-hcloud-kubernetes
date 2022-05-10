module "cluster" {
  source            = "./modules/cluster"
  hcloud_token      = var.hcloud_token
  hcloud_ssh_private_key = var.hcloud_ssh_private_key
  cluster_name      = var.cluster_name
  location          = var.location
  image             = var.image
  network_zone      = var.network_zone
  network_ip_range  = var.network_ip_range
  subnet_ip_range   = var.subnet_ip_range
  master_type       = var.master_type
  master_count      = var.master_count
  mastername_format = var.mastername_format
  worker_type       = var.worker_type
  worker_count      = var.worker_count
  workername_format = var.workername_format
}

module "firewall" {
  source          = "./modules/firewall"
  hcloud_ssh_private_key = var.hcloud_ssh_private_key
  connections     = module.cluster.all_nodes.*.ipv4_address
  subnet_ip_range = var.subnet_ip_range
}

module "kubernetes" {
  source             = "./modules/kubernetes"
  hcloud_ssh_private_key = var.hcloud_ssh_private_key
  hcloud_token       = var.hcloud_token
  network_id         = module.cluster.network_id
  cluster_name       = var.cluster_name
  master_nodes       = module.cluster.master_nodes
  worker_nodes       = module.cluster.worker_nodes
  private_ips        = module.cluster.private_ips
  kubernetes_version = var.kubernetes_version
  kubeconfig_path    = var.kubeconfig_path
}
