
# Create an Application Load Balancer (ALB) security group
resource "aws_security_group" "alb_sg" {
  name        = "sg.alb-soar"
  vpc_id = aws_vpc.claranet.id
  description = "Security group for Application Load Balancer"

  ingress {
    from_port   = 80
    to_port     = 80
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

# Create an EC2 security group that allows ingress traffic only from the ALB security group
resource "aws_security_group" "ec2_sg" {
  name        = "sg.ec2-soar"
  vpc_id = aws_vpc.claranet.id
  description = "Security group for EC2 instance"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an RDS security group that allows ingress traffic from EC2 security group
resource "aws_security_group" "rds_sg" {
  name        = "sg.rds-soar"
  vpc_id = aws_vpc.claranet.id
  description = "Security group for RDS instance"

  ingress {
    from_port       = 3306  # Assuming MySQL, adjust port accordingly for other database engines
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}