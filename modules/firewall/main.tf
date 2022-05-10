# firewall/main.tf

variable "connections" {
  type = list(any)
}

variable "subnet_ip_range" {
  type = string
}

variable "hcloud_ssh_private_key" {
  type = string
}

resource "null_resource" "firewall" {
  count = length(var.connections)

  triggers = {
    template = data.template_file.ufw.rendered
  }


  connection {
    host  = element(var.connections, count.index)
    user  = "root"
    type  = "ssh"
    private_key = file("${var.hcloud_ssh_private_key}")
    agent = false
  }

  provisioner "remote-exec" {
    inline = [
      data.template_file.ufw.rendered
    ]
  }
}

data "template_file" "ufw" {
  template = file("${path.module}/scripts/ufw.sh")

  vars = {
    subnet_ip_range = var.subnet_ip_range
  }
}
