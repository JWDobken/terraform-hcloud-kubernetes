# cluster/main.tf

locals {
  server_count = var.master_count + var.worker_count
  servers      = concat(hcloud_server.master_node, hcloud_server.worker_node)
}

resource "hcloud_server" "master_node" {
  count       = var.master_count
  name        = "${var.cluster_name}-master-${count.index + 1}"
  location    = var.location
  image       = var.image
  server_type = var.master_type
  ssh_keys    = var.hcloud_ssh_keys

  labels = {
    master = true
  }

  connection {
    user    = "root"
    type    = "ssh"
    timeout = "2m"
    host    = self.ipv4_address
  }

  provisioner "file" {
    content     = data.template_file.floating_ip.rendered
    destination = "/etc/network/interfaces.d/60-floating-ip.cfg"
  }

  provisioner "remote-exec" {
    inline = [
      "while fuser /var/{lib/{dpkg,apt/lists},cache/apt/archives}/lock >/dev/null 2>&1; do sleep 1; done",
      "apt-get update",
      "apt-get install -yq ufw jq",
    ]
  }
}

resource "hcloud_server" "worker_node" {
  count       = var.worker_count
  name        = "${var.cluster_name}-worker-${count.index + 1}"
  location    = var.location
  image       = var.image
  server_type = var.worker_type
  ssh_keys    = var.hcloud_ssh_keys

  labels = {
    master = false
  }

  connection {
    user    = "root"
    type    = "ssh"
    timeout = "2m"
    host    = self.ipv4_address
  }

  provisioner "file" {
    content     = data.template_file.floating_ip.rendered
    destination = "/etc/network/interfaces.d/60-floating-ip.cfg"
  }

  provisioner "remote-exec" {
    inline = [
      "while fuser /var/{lib/{dpkg,apt/lists},cache/apt/archives}/lock >/dev/null 2>&1; do sleep 1; done",
      "apt-get update",
      "apt-get install -yq ufw jq"
    ]
  }
}

resource "hcloud_network" "kubernetes_network" {
  name     = var.cluster_name
  ip_range = var.network_ip_range
}

resource "hcloud_network_subnet" "kubernetes_subnet" {
  network_id   = hcloud_network.kubernetes_network.id
  type         = "server"
  network_zone = var.network_zone
  ip_range     = var.subnet_ip_range
}

resource "hcloud_server_network" "private_network" {
  count     = local.server_count
  server_id = element(local.servers.*.id, count.index)
  subnet_id = hcloud_network_subnet.kubernetes_subnet.id
}

data "template_file" "floating_ip" {
  template = file("${path.module}/files/60-floating-ip.cfg")

  vars = {
    loadbalancer_ip = var.loadbalancer_ip
  }
}
