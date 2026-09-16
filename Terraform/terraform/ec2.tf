data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_iam_instance_profile" "lab_profile" {
  name = var.lab_instance_profile_name
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  key_name                    = aws_key_pair.main.key_name
  associate_public_ip_address = true
  iam_instance_profile        = data.aws_iam_instance_profile.lab_profile.name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-server"
  }

  provisioner "local-exec" {
    working_dir = path.module
    interpreter = ["bash", "-c"]

    command = <<-EOT
      set -e
      echo "[Terraform] EC2 criada: ${self.public_ip}"
      mkdir -p ../ansible/inventory
      cat > ../ansible/inventory/hosts.yml <<EOF
all:
  hosts:
    app_server:
      ansible_host: ${self.public_ip}
      ansible_user: ec2-user
      ansible_ssh_private_key_file: ${pathexpand(var.private_key_path)}
      ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
      ansible_python_interpreter: /usr/bin/python3
      public_ip: ${self.public_ip}
      kind_cluster_name: ${var.kind_cluster_name}
      kind_api_port: ${var.kind_api_port}
      kind_http_port: ${var.kind_http_port}
      kind_https_port: ${var.kind_https_port}
EOF
      chmod 600 ../ansible/inventory/hosts.yml
      bash ../scripts/deploy-ansible.sh
    EOT
  }
}
