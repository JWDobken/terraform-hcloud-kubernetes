# kubernetes/kubeadm_join.tf

resource "null_resource" "kubeadm_join" {
  count      = length(var.worker_nodes)
  depends_on = [null_resource.install]

  connection {
    host  = element(var.worker_nodes.*.ipv4_address, count.index)
    user  = "root"
    agent = true
  }

  provisioner "local-exec" {
    command = <<EOT
      ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        root@${local.master_ip} 'echo $(kubeadm token create) > /tmp/kubeadm_token'
    EOT
  }

  provisioner "local-exec" {
    command = <<EOT
      scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        root@${local.master_ip}:/tmp/kubeadm_token \
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
    master_private_ip = local.master_private_ip
  }
}
