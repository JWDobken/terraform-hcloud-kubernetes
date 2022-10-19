# kubernetes/kubeadm_join.tf

resource "null_resource" "kubeadm_join" {
  count      = length(var.worker_nodes)
  depends_on = [null_resource.install]

  connection {
    host        = element(var.worker_nodes.*.ipv4_address, count.index)
    type        = "ssh"
    private_key = var.private_key
  }

  provisioner "local-exec" {
    command = <<EOT
      eval "$(ssh-agent -s)"
      echo "${var.private_key}" | tr -d '\r' | ssh-add -
      ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        root@${local.control_plane_ip} 'echo $(kubeadm token create) > /tmp/kubeadm_token'
    EOT
  }

  provisioner "local-exec" {
    command = <<EOT
      eval "$(ssh-agent -s)"
      echo "${var.private_key}" | tr -d '\r' | ssh-add -
      scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        root@${local.control_plane_ip}:/tmp/kubeadm_token \
        /tmp/kubeadm_token
    EOT
  }

  provisioner "file" {
    source      = "/tmp/kubeadm_token"
    destination = "/tmp/kubeadm_token"
  }

  provisioner "remote-exec" {
    inline = [
      data.template_file.worker.rendered
    ]
  }
}

data "template_file" "worker" {
  template = file("${path.module}/scripts/worker.sh")

  vars = {
    control_plane_private_ip = local.control_plane_private_ip
  }
}
