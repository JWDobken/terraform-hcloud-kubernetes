# kubernetes/main.tf

locals {
  connections              = concat(var.control_plane_nodes, var.worker_nodes).*.ipv4_address
  control_plane_ip         = element(var.control_plane_nodes.*.ipv4_address, 0)
  control_plane_private_ip = var.private_ips[0]
}

resource "null_resource" "install" {
  count = length(local.connections)

  connection {
    host        = element(local.connections, count.index)
    type        = "ssh"
    private_key = var.private_key
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
      element(data.template_file.install.*.rendered, count.index)
    ]
  }

  provisioner "file" {
    content     = data.template_file.access_tokens.rendered
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
      count.index < length(var.control_plane_nodes) ? data.template_file.control_plane.rendered : "echo skip"
    ]
  }
}

data "template_file" "install" {
  count    = length(local.connections)
  template = file("${path.module}/scripts/install.sh")

  vars = {
    kubernetes_version = var.kubernetes_version
  }
}

data "template_file" "control_plane" {
  template = file("${path.module}/scripts/control_plane.sh")

  vars = {
    kubernetes_version = var.kubernetes_version
    control_plane_ip   = local.control_plane_ip
    cluster_name       = var.cluster_name
  }
}

data "template_file" "access_tokens" {
  template = file("${path.module}/files/access_tokens.yaml")

  vars = {
    hcloud_token = var.hcloud_token
    network_id   = var.network_id
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
