resource "aws_security_group" "eshop" {
  name        = "eshop-security-group"
  description = "Security group for E-SHOP application"
  
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "eshop_ec2_role" {
  name = "eshop-ec2-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "eshop_ec2_policy" {
  name   = "eshop-ec2-policy"
  role   = aws_iam_role.eshop_ec2_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::eshop-${data.aws_caller_identity.current.account_id}",
          "arn:aws:s3:::eshop-${data.aws_caller_identity.current.account_id}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "eshop" {
  name = "eshop-instance-profile"
  role = aws_iam_role.eshop_ec2_role.name
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_eip" "eshop" {
  domain            = "vpc"
  depends_on        = [aws_internet_gateway.main]
  
  tags = {
    Name = "eshop-elastic-ip"
  }
}

data "aws_caller_identity" "current" {}

resource "aws_instance" "eshop" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.eshop.name
  vpc_security_group_ids = [aws_security_group.eshop.id]
  
  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }
  
  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    domain_name = var.domain_name
    email       = var.email
  }))
  
  monitoring = var.enable_monitoring
  
  tags = {
    Name = "eshop-application"
  }
  
  depends_on = [aws_internet_gateway_attachment.main]
}

resource "aws_eip_association" "eshop" {
  instance_id      = aws_instance.eshop.id
  allocation_id    = aws_eip.eshop.id
}

resource "aws_cloudwatch_log_group" "eshop" {
  name              = "/eshop/application"
  retention_in_days = 30
  
  tags = {
    Name = "eshop-logs"
  }
}

resource "aws_cloudwatch_metric_alarm" "instance_status" {
  count               = var.enable_monitoring ? 1 : 0
  alarm_name          = "eshop-instance-status-check"
  alarm_description   = "Alert if EC2 instance status checks fail"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "0"
  
  dimensions = {
    InstanceId = aws_instance.eshop.id
  }
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  count               = var.enable_monitoring ? 1 : 0
  alarm_name          = "eshop-high-cpu"
  alarm_description   = "Alert if CPU usage is high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  
  dimensions = {
    InstanceId = aws_instance.eshop.id
  }
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "eshop-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "eshop-subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "eshop-igw"
  }
}

resource "aws_internet_gateway_attachment" "main" {
  internet_gateway_id = aws_internet_gateway.main.id
  vpc_id              = aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }
  
  tags = {
    Name = "eshop-rt"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_network_interface" "eshop" {
  subnet_id       = aws_subnet.main.id
  security_groups = [aws_security_group.eshop.id]
  
  tags = {
    Name = "eshop-eni"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_s3_bucket" "backups" {
  count  = var.enable_backup ? 1 : 0
  bucket = "eshop-backups-${data.aws_caller_identity.current.account_id}"
  
  tags = {
    Name = "eshop-backups"
  }
}

resource "aws_s3_bucket_versioning" "backups" {
  count  = var.enable_backup ? 1 : 0
  bucket = aws_s3_bucket.backups[0].id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "backups" {
  count  = var.enable_backup ? 1 : 0
  bucket = aws_s3_bucket.backups[0].id
  
  rule {
    id     = "delete-old-backups"
    status = "Enabled"
    
    expiration {
      days = var.backup_retention_days
    }
    
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}
