output "vpc_id_primary" {
    description = "The ID of the VPC"
    value       = aws_vpc.claranet.id
}

output "public_subnet_info" {
  description = "List of information for the created public subnets"
  value       = [
    for subnet in aws_subnet.public_subnets :
    {
      id    = subnet.id
      name  = subnet.tags["Name"]
      cidr  = subnet.cidr_block
    }
  ]
}
output "private_subnet_info" {
  description = "List of information for the created private subnets"
  value       = [
    for subnet in aws_subnet.private_subnets :
    {
      id    = subnet.id
      name  = subnet.tags["Name"]
      cidr  = subnet.cidr_block
    }
  ]
}

output "ALB_SecurityGroup_ID" {
  value = aws_security_group.alb_sg.id
}
output "EC2_SecurityGroup_ID" {
  value = aws_security_group.ec2_sg.id
}
output "RDS_SecurityGroup_ID" {
  value = aws_security_group.rds_sg.id
}
output "EC2_Subnet" {
  value = aws_instance.ec2_instance.subnet_id
}
output "RDS_Endpoint" {
  value = aws_db_instance.claranet.endpoint
}
output "ALB_Endpoint" {
  value = aws_lb.claranet.dns_name
}