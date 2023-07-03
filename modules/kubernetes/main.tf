# kubernetes/main.tf

locals {
  connections              = concat(var.control_plane_nodes, var.worker_nodes).*.ipv4_address
  control_plane_ip         = element(var.control_plane_nodes.*.ipv4_address, 0)
  control_plane_private_ip = var.private_ips[0]
}

resource "null_resource" "install" {
  count = length(local.connections)

  connection {
    type  = "ssh"
    host  = element(local.connections, count.index)
    user  = "root"
    agent = true
  }

  provisioner "remote-exec" {
    inline = [
      "[ -d /etc/systemd/system/kubelet.service.d ] || mkdir -p /etc/systemd/system/kubelet.service.d",
      "[ -d /etc/systemd/system/docker.service.d ] || mkdir -p /etc/systemd/system/docker.service.d"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/files/00-cgroup-systemd.conf"
    destination = "/etc/systemd/system/docker.service.d/00-cgroup-systemd.conf"
  }

  provisioner "file" {
    source      = "${path.module}/files/10-docker-opts.conf"
    destination = "/etc/systemd/system/docker.service.d/10-docker-opts.conf"
  }

  provisioner "file" {
    source      = "${path.module}/files/20-hetzner-cloud.conf"
    destination = "/etc/systemd/system/kubelet.service.d/20-hetzner-cloud.conf"
  }

  provisioner "file" {
    source      = "${path.module}/files/sysctl.conf"
    destination = "/etc/sysctl.conf"
  }

  provisioner "remote-exec" {
    inline = [
      templatefile("${path.module}/scripts/install.sh", { kubernetes_version = var.kubernetes_version })
    ]
  }

  provisioner "file" {
    content = templatefile("${path.module}/files/access_tokens.yaml", {
      hcloud_token = var.hcloud_token,
      network_id   = var.network_id
    })
    destination = "/tmp/access_tokens.yaml"
  }

  provisioner "file" {
    source      = "${path.module}/files/ccm-networks.yaml"
    destination = "/tmp/ccm-networks.yaml"
  }

  provisioner "file" {
    source      = "${path.module}/files/kube-flannel.yaml"
    destination = "/tmp/kube-flannel.yaml"
  }

  provisioner "file" {
    source      = "${path.module}/files/hcloud-csi.yaml"
    destination = "/tmp/hcloud-csi.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      count.index < length(var.control_plane_nodes) ? templatefile("${path.module}/scripts/control_plane.sh", { kubernetes_version = var.kubernetes_version, control_plane_ip = local.control_plane_ip, cluster_name = var.cluster_name }) : "echo skip"
    ]
  }
}

module "kubeconfig" {
  source     = "matti/resource/shell"
  depends_on = [null_resource.kubeadm_join]

  trigger = element(var.control_plane_nodes.*.ipv4_address, 0)

  command = <<EOT
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
      root@${local.control_plane_ip} 'cat /root/.kube/config'
  EOT
}

module "endpoint" {
  source     = "matti/resource/shell"
  depends_on = [null_resource.kubeadm_join]

  trigger = element(var.control_plane_nodes.*.ipv4_address, 0)

  command = <<EOT
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
      root@${local.control_plane_ip} 'kubectl config --kubeconfig /root/.kube/config view -o jsonpath='{.clusters[0].cluster.server}''
  EOT
}

module "certificate_authority_data" {
  source     = "matti/resource/shell"
  depends_on = [null_resource.kubeadm_join]

  trigger = element(var.control_plane_nodes.*.ipv4_address, 0)

  command = <<EOT
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
      root@${local.control_plane_ip} 'kubectl config --kubeconfig /root/.kube/config view --flatten -o jsonpath='{.clusters[0].cluster.certificate-authority-data}''
  EOT
}

module "client_certificate_data" {
  source     = "matti/resource/shell"
  depends_on = [null_resource.kubeadm_join]

  trigger = element(var.control_plane_nodes.*.ipv4_address, 0)

  command = <<EOT
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
      root@${local.control_plane_ip} 'kubectl config --kubeconfig /root/.kube/config view --flatten -o jsonpath='{.users[0].user.client-certificate-data}''
  EOT
}

module "client_key_data" {
  source     = "matti/resource/shell"
  depends_on = [null_resource.kubeadm_join]

  trigger = element(var.control_plane_nodes.*.ipv4_address, 0)

  command = <<EOT
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
      root@${local.control_plane_ip} 'kubectl config --kubeconfig /root/.kube/config view --flatten -o jsonpath='{.users[0].user.client-key-data}''
  EOT
}
