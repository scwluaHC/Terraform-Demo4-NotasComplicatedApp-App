region = "us-east-1"

instance_type = "t2.micro"

amis = "ami-0dc2d3e4c0f9ebd18"

availability_zones_1 = "us-east-1a"

availability_zones_2 = "us-east-1b"

allowed_cidr_blocks = "0.0.0.0/0"

vpc_name = "scwlua-demo-vpc"

ig_name = "scwlua-demo-ig"

pub_subnet1 = "scwlua-pub-subnet1"

pub_subnet2 = "scwlua-pub-subnet2"

web_sg1 = "scwlua-web-sg1"

web_sg2 = "scwlua-web-sg2"

database_name = "scwluadb"

database_user = "scwlua"

database_password = "Testing123"

endpoint = "http://mydb.scwlua.com"

rds_subnet1 = "db-subnet1"

rds_subnet2 = "db-subnet2"

rds_subnet_grp = "db-subnet-grp"

sg_for_rds = "db-sg"

db_instance_name = "scwlua-db"

instance_name = "mynew-appserver"

alb_sg = "scwlua-alb-sg"

alb_name = "scwlua-alb"