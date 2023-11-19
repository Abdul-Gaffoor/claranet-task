variable "aws-config" {
  type = map(string)
  description = "AWS Account Information"
}

variable "vpc-config" {
  type = map(string)
  description = "VPC Information"
}

variable "resource-config" {
  type = map(string)
  description = "Resource Information"
}

