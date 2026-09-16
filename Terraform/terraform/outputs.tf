output "public_ip" {
  description = "IP público da EC2."
  value       = aws_instance.app.public_ip
}

output "application_url" {
  description = "URL da aplicação."
  value       = "http://${aws_instance.app.public_ip}:${var.app_port}"
}

output "instance_id" {
  description = "ID da EC2."
  value       = aws_instance.app.id
}
