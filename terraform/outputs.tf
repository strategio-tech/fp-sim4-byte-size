output "domain-name" {
    value = aws_instance.web.public_dns
}

output "web-address" {
  value = "${aws_instance.web.public_dns}:${var.app_port}"
}