variable "count" {}

variable "bastion_host" {}

variable "ssh_user" {
  default = "root"
}

variable "ssh_private_key" {
  default = "~/.ssh/id_rsa.insecure"
}

variable "connections" {
  type = "list"
}

variable "private_interface" {
  type = "string"
}

variable "vpn_interface" {
  type = "string"
}

variable "vpn_port" {
  type = "string"
}

resource "null_resource" "firewall" {
  count = "${var.count}"

  triggers = {
    template = "${data.template_file.ufw.rendered}"
  }

  connection {
    type                = "ssh"
    host                = "${element(var.connections, count.index)}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${var.bastion_host}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
  }

  provisioner "remote-exec" {
    inline = <<EOF
${data.template_file.ufw.rendered}
EOF
  }
}

data "template_file" "ufw" {
  template = "${file("${path.module}/scripts/ufw.sh")}"

  vars {
    private_interface = "${var.private_interface}"
    vpn_interface     = "${var.vpn_interface}"
    vpn_port          = "${var.vpn_port}"
  }
}