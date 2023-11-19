#### EC2_Creation

## To Generate Private Key
resource "tls_private_key" "rsa_4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
## Create Key Pair for Connecting EC2 via SSH
resource "aws_key_pair" "key_pair" {
  key_name   = var.resource-config.key_name
  public_key = tls_private_key.rsa_4096.public_key_openssh
}
## Save PEM file locally
resource "local_file" "private_key" {
  content  = tls_private_key.rsa_4096.private_key_pem
  filename = var.resource-config.key_name
}

resource "aws_instance" "ec2_instance" {
  ami           = var.resource-config.ec2_ami_id
  instance_type = var.resource-config.ec2_instance_type
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id             = element(aws_subnet.private_subnets[*].id, 0)
  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }

  tags = {
    Name = var.resource-config.ec2_name
  }
}

#### RDS_Creation
resource "aws_db_subnet_group" "claranet" {
  name       = "db-subnetgroup"
  subnet_ids = [element(aws_subnet.private_subnets[*].id, 0), element(aws_subnet.private_subnets[*].id, 1)]

  tags = {
    Name = "My DB subnet group"
  }
}
resource "aws_db_instance" "claranet" {
  allocated_storage      = 30
  identifier             = var.resource-config.db_identifier
  db_name                = var.resource-config.dbname
  db_subnet_group_name   = aws_db_subnet_group.claranet.name
  engine                 = var.resource-config.dbengine
  engine_version         = var.resource-config.engine_version
  instance_class         = var.resource-config.rds_instance_type
  username               = var.resource-config.db_username
  password               = var.resource-config.db_password
  publicly_accessible    = true
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

#### ALB_Creation
# Create Target group
resource "aws_lb_target_group" "claranet" {
  name       = "Demo-TargetGroup-tf"
  depends_on = [aws_vpc.claranet]
  port       = 80
  protocol   = "HTTP"
  vpc_id     = aws_vpc.claranet.id
  health_check {
    interval            = 70
    path                = "/index.html"
    port                = 80
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 60
    protocol            = "HTTP"
    matcher             = "200,202"
  }
}
resource "aws_lb_target_group_attachment" "claranet" {
  target_group_arn = aws_lb_target_group.claranet.arn
  target_id        = aws_instance.ec2_instance.id
}
# Create ALB Listener 
resource "aws_lb_listener" "claranet" {
  load_balancer_arn = aws_lb.claranet.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.claranet.arn
  }
}
# Create ALB
resource "aws_lb" "claranet" {
  name               = var.resource-config.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [element(aws_subnet.private_subnets[*].id, 0), element(aws_subnet.private_subnets[*].id, 1)]

  tags = {
    name    = "Demo-AppLoadBalancer-tf"
  }
}