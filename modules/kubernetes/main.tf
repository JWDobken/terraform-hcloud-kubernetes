# kubernetes/main.tf

locals {
  connections       = concat(var.master_nodes, var.worker_nodes).*.ipv4_address
  master_ip         = element(var.master_nodes.*.ipv4_address, 0)
  master_private_ip = var.private_ips[0]
}

resource "null_resource" "install" {
  count = length(local.connections)

  connection {
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
      "${element(data.template_file.install.*.rendered, count.index)}"
    ]
  }

  provisioner "file" {
    content     = data.template_file.access_tokens.rendered
    destination = "/tmp/access_tokens.conf"
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
      "${count.index < length(var.master_nodes) ? data.template_file.master.rendered : "echo skip"}"
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

data "template_file" "master" {
  template = file("${path.module}/scripts/master.sh")

  vars = {
    kubernetes_version = var.kubernetes_version
    master_ip          = local.master_ip
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