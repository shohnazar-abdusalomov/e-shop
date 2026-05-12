output "instance_id" {
  description = "Instance ID"
  value       = aws_instance.eshop.id
}

output "instance_public_ip" {
  description = "Public IP of the instance"
  value       = aws_eip.eshop.public_ip
}

output "elastic_ip_allocation_id" {
  description = "Elastic IP Allocation ID"
  value       = aws_eip.eshop.id
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.eshop.id
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i /path/to/your-key.pem ubuntu@${aws_eip.eshop.public_ip}"
}

output "application_url" {
  description = "Application URL (HTTP)"
  value       = "http://${aws_eip.eshop.public_ip}"
}

output "application_url_ssl" {
  description = "Application URL (HTTPS) - if domain configured"
  value       = "https://${var.domain_name}"
}

output "application_url_domain" {
  description = "Application URL by domain name"
  value       = "http://${var.domain_name}"
}

output "cloudwatch_log_group" {
  description = "CloudWatch Log Group name"
  value       = aws_cloudwatch_log_group.eshop.name
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "Subnet ID"
  value       = aws_subnet.main.id
}

output "backup_bucket_name" {
  description = "S3 Backup Bucket name"
  value       = try(aws_s3_bucket.backups[0].id, "N/A")
}

output "iam_role_name" {
  description = "IAM Role name for EC2 instance"
  value       = aws_iam_role.eshop_ec2_role.name
}

output "terraform_outputs" {
  description = "All important outputs for reference"
  value = {
    instance_ip      = aws_eip.eshop.public_ip
    instance_id      = aws_instance.eshop.id
    security_group   = aws_security_group.eshop.id
    application_url  = "http://${aws_eip.eshop.public_ip}"
    ssh_command      = "ssh -i /path/to/your-key.pem ubuntu@${aws_eip.eshop.public_ip}"
  }
}
