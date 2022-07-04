# AWS specific
variable "region" {
  description = "Value of the regions"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Value of the instance type"
  type        = string
  default     = "t2.micro"
}

variable "amis" {
  description = "Map for ami type"
  type        = string
  default = "ami-0dc2d3e4c0f9ebd18"
  }

variable "availability_zones_1" {
  description = "AZ1"
  type        = string
  default     = "us-east-1a"
}

variable "availability_zones_2" {
  description = "AZ2"
  type        = string
  default     = "us-east-1b"
}

# VPC and network specific
variable "allowed_cidr_blocks" {
  default = "0.0.0.0/0"
}

variable "vpc_name" {
  type    = string
  default = "scwlua-demo-vpc"
}

variable "ig_name" {
  type    = string
  default = "scwlua-demo-ig"
}

variable "pub_subnet1" {
  type    = string
  default = "scwlua-pub-subnet1"
}

variable "pub_subnet2" {
  type    = string
  default = "scwlua-pub-subnet2"
}

variable "web_sg1" {
  type    = string
  default = "scwlua-web-sg1"
}

variable "web_sg2" {
  type    = string
  default = "scwlua-web-sg2"
}

# RDS specific
variable "database_name" {
  description = "Name of database"
  type        = string
  default     = "scwluadb"
}

variable "database_user" {
  description = "DB username"
  type        = string
  default     = "scwlua"
}

variable "database_password" {
  description = "DB user password"
  type        = string
  default     = "Testing123"
}

variable "endpoint" {
  description = "Value of the endpoint"
  type        = string
  default     = "http://mydb.scwlua.com"
}

variable "rds_subnet1" {
  description = "rds subnet1"
  type        = string
  default     = "db-subnet1"
}

variable "rds_subnet2" {
  description = "rds subnet2"
  type        = string
  default     = "db-subnet2"
}

variable "rds_subnet_grp" {
  description = "rds group"
  type        = string
  default     = "db-subnet-grp"
}

variable "sg_for_rds" {
  description = "rds sg group"
  type        = string
  default     = "db-sg"
}

variable "db_instance_name" {
  description = "db instance name"
  type        = string
  default     = "scwlua-db"
}

# EC2 specific
variable "instance_name" {
  description = "EC2 name"
  type        = string
  default     = "mynew-appserver"
}

# LB specific
variable "alb_sg" {
  description = "ALB SG name"
  type        = string
  default     = "scwlua-alb-sg"
}

variable "alb_name" {
  description = "ALB name"
  type        = string
  default     = "scwlua-alb"
}

# Terraform specific
#variable "path" {
#  description = "tfstate path"
#  type        = string
#  default     = "../vault-admin-workspace/terraform.tfstate"
#}