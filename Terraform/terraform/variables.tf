variable "aws_region" {
  description = "Região AWS."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto."
  type        = string
  default     = "cloud-lab-02"
}

variable "ssh_cidr" {
  description = "CIDR permitido para SSH. Para laboratório pode ser 0.0.0.0/0."
  type        = string
  default     = "0.0.0.0/0"
}

variable "key_name" {
  description = "Nome do Key Pair na AWS."
  type        = string
  default     = "cloud-lab-02-key"
}

variable "public_key_path" {
  description = "Caminho da chave pública."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "private_key_path" {
  description = "Caminho da chave privada."
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "instance_type" {
  description = "Tipo da instância. t3.small é o mínimo recomendado para rodar Docker + kind (t3.micro não tem memória suficiente para o cluster)."
  type        = string
  default     = "t3.small"
}

variable "app_port" {
  description = "Porta publicada da aplicação."
  type        = number
  default     = 3000
}

variable "kind_cluster_name" {
  description = "Nome do cluster kind criado dentro da EC2."
  type        = string
  default     = "devops-labs"
}

variable "kind_api_port" {
  description = "Porta em que a API do Kubernetes (kind) fica exposta."
  type        = number
  default     = 6443
}

variable "kind_http_port" {
  description = "Porta do host mapeada para o ingress-nginx (HTTP)."
  type        = number
  default     = 80
}

variable "kind_https_port" {
  description = "Porta do host mapeada para o ingress-nginx (HTTPS)."
  type        = number
  default     = 443
}

variable "root_volume_size" {
  description = "Tamanho (GB) do volume raiz."
  type        = number
  default     = 30
}

variable "lab_instance_profile_name" {
  description = "Instance profile do AWS Academy Learner Lab."
  type        = string
  default     = "LabInstanceProfile"
}