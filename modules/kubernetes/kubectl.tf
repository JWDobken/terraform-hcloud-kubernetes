# kubernetes/kubectl.tf

resource "null_resource" "kubectl" {
  depends_on = [null_resource.kubeadm_join]

  triggers = {
    ip = element(var.master_nodes.*.ipv4_address, 0)
  }

  provisioner "local-exec" {
    command = <<EOT
      mkdir -p $HOME/.kube
      scp -oStrictHostKeyChecking=no \
        root@${local.master_ip}:/root/.kube/config \
        $HOME/.kube/${var.cluster_name}.conf
EOT
  }
}
