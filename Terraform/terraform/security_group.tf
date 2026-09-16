resource "aws_security_group" "app" {
  name        = "${var.project_name}-sg"
  description = "Security Group da aplicacao"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    description = "Aplicacao"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Ingress HTTP (ingress-nginx no kind)"
    from_port   = var.kind_http_port
    to_port     = var.kind_http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Ingress HTTPS (ingress-nginx no kind)"
    from_port   = var.kind_https_port
    to_port     = var.kind_https_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "API do Kubernetes (kind) para OpenLens/Freelens"
    from_port   = var.kind_api_port
    to_port     = var.kind_api_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Saida para internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}
