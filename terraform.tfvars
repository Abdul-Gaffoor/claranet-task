# AWS Account Details
aws-config = {
    access_key          = "AKIAT2NEKR3QMM3EYQXZ" # Note These are Dummy
    secret_key          = "rd0oZwHTytzUpRlb6iTd/Kt//BkZnJp+BTLC50nF" # Note These are Dummy
    region_primary      = "ap-south-1"
    environment         = "Claranet_Task_For_Abdul"
    owner               = "Claranet"
}
# VPC Details
vpc-config = {
    name                              = "vpc-soar"
    cidr                              = "10.20.30.0/24"
    public_subnet_name                = "subnet-soar-public"
    private_subnet_name               = "subnet-soar-private"
    internet_gateway_name             = "ig-soar"
    internet_gateway_routetable_name  = "ig-rt-soar"
    nat_gateway_name                  = "nat-gw-soar"
    nat_gateway_routetable_name       = "natgw-rt-soar"
    nat_gateway_eip_name              = "nat-eip"
}
# Resource Details
resource-config = {
    alb_sg_name                   = "sg.alb-soar"
    ec2_sg_name                   = "sg.ec2-soar"
    rds_sg_name                   = "sg.rds-soar"
    ec2_instance_type             = "t2.micro"
    key_name                      = "claranet-task"
    ec2_ami_id                    = "ami-0287a05f0ef0e9d9a"
    ec2_name                      = "ec2-soar"
    db_identifier                 = "claranet-rds"
    dbname                        = "claranettestdb"
    dbengine                      = "mysql"
    rds_instance_type             = "db.t3.micro"
    engine_version                = "5.7"
    db_username                   = "admin"
    db_password                   = "helloworld7891!"
    alb_name                      = "Applications-LB"
    
}
