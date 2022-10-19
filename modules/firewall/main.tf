# firewall/main.tf

variable "connections" {
  type = list(any)
}

variable "subnet_ip_range" {
  type = string
}

variable "private_key" {
  type      = string
  sensitive = true
}

resource "null_resource" "firewall" {
  count = length(var.connections)

  triggers = {
    template = data.template_file.ufw.rendered
  }

  connection {
    host        = element(var.connections, count.index)
    type        = "ssh"
    private_key = var.private_key
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
