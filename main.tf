module "cluster" {
  source                    = "./modules/cluster"
  hcloud_token              = var.hcloud_token
  hcloud_ssh_keys           = var.hcloud_ssh_keys
  cluster_name              = var.cluster_name
  location                  = var.location
  image                     = var.image
  network_zone              = var.network_zone
  network_ip_range          = var.network_ip_range
  subnet_ip_range           = var.subnet_ip_range
  control_plane_type        = var.control_plane_type
  control_plane_count       = var.control_plane_count
  control_plane_name_format = var.control_plane_name_format
  worker_type               = var.worker_type
  worker_count              = var.worker_count
  worker_name_format        = var.worker_name_format
}

module "firewall" {
  source          = "./modules/firewall"
  connections     = module.cluster.all_nodes.*.ipv4_address
  subnet_ip_range = var.subnet_ip_range
}

module "kubernetes" {
  source              = "./modules/kubernetes"
  hcloud_token        = var.hcloud_token
  network_id          = module.cluster.network_id
  cluster_name        = var.cluster_name
  control_plane_nodes = module.cluster.control_plane_nodes
  worker_nodes        = module.cluster.worker_nodes
  private_ips         = module.cluster.private_ips
  kubernetes_version  = var.kubernetes_version
}
