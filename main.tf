provider "aws" {
  profile = "default"
  region  = var.region
}

data "terraform_remote_state" "RBAC_NetworkTeam" {
  backend = "remote"
  config = {
    organization = "scwlua-test"
    workspaces = {
      name = "Terraform-Demo4-NotasComplicatedApp-Network"
    }
  }
}

## DEPLOYMENT PORTION TO AWS ##

# Setup the RDS options group
resource "aws_db_option_group" "rds" {
  name                     = "optiongroup-test-terraform"
  option_group_description = "Terraform Option Group"
  engine_name              = "mysql"
  major_engine_version     = "5.7"
  option {
    option_name = "MARIADB_AUDIT_PLUGIN"
    option_settings {
      name  = "SERVER_AUDIT_EVENTS"
      value = "CONNECT"
    }
    option_settings {
      name  = "SERVER_AUDIT_FILE_ROTATIONS"
      value = "37"
    }
  }
}

# Create DB param group
resource "aws_db_parameter_group" "rds" {
  name   = "rdsmysql"
  family = "mysql5.7"
  parameter {
    name  = "autocommit"
    value = "1"
  }
  parameter {
    name  = "binlog_error_action"
    value = "IGNORE_ERROR"
  }
}

# Create DB instance
resource "aws_db_instance" "rds" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  name                   = var.database_name
  username               = var.database_user
  password               = var.database_password
  db_subnet_group_name   = data.terraform_remote_state.RBAC_NetworkTeam.outputs.aws_db_subnet_grp_id
  option_group_name      = aws_db_option_group.rds.id
  publicly_accessible    = "false"
  vpc_security_group_ids = ["${aws_security_group.rds.id}"]
  parameter_group_name   = aws_db_parameter_group.rds.id
  skip_final_snapshot    = true
  tags = {
    Name = var.db_instance_name
  }
}

# EC2 RELATED #
# Create EC2 Instance
resource "aws_instance" "app_server" {
  ami                                  = var.amis[var.region]
  instance_type                        = "t2.micro"
  associate_public_ip_address          = true
  vpc_security_group_ids               = ["${data.terraform_remote_state.RBAC_NetworkTeam.outputs.aws_web_sg1_id}", "${data.terraform_remote_state.RBAC_NetworkTeam.outputs.aws_web_sg2_id}"]
  subnet_id                            = data.terraform_remote_state.RBAC_NetworkTeam.outputs.aws_websubnet2_id
  user_data                            = templatefile("user_data.tftpl", { rds_endpoint = "${aws_db_instance.rds.endpoint}", user = var.database_user, password = var.database_password, dbname = var.database_name })
  instance_initiated_shutdown_behavior = "terminate"
  root_block_device {
    volume_type = "gp2"
    volume_size = "15"
  }
  tags = {
    Name = var.instance_name
  }
}

# Create an AMI based on the EC2 instance app_server
resource "aws_ami_from_instance" "ec2_image" {
  # added aws_alb.alb to depends_on
  depends_on         = [aws_instance.app_server, aws_alb.alb]
  name               = "demo-ami"
  source_instance_id = aws_instance.app_server.id
}

# Create autoscaling launch config
resource "aws_launch_configuration" "ec2" {
  depends_on      = [aws_ami_from_instance.ec2_image]
  image_id        = aws_ami_from_instance.ec2_image.id
  instance_type   = "t2.micro"
  security_groups = ["${data.terraform_remote_state.RBAC_NetworkTeam.outputs.aws_web_sg1_id}", "${data.terraform_remote_state.RBAC_NetworkTeam.outputs.aws_web_sg2_id}"]
  lifecycle {
    create_before_destroy = true
  }
}

# Create autoscaling group
resource "aws_autoscaling_group" "ec2" {
  depends_on           = [aws_launch_configuration.ec2]
  launch_configuration = aws_launch_configuration.ec2.id
  min_size             = 2
  max_size             = 3
  target_group_arns    = ["${aws_alb_target_group.group.arn}"]
  vpc_zone_identifier  = ["${data.terraform_remote_state.RBAC_NetworkTeam.outputs.aws_websubnet1_id}", "${data.terraform_remote_state.RBAC_NetworkTeam.outputs.aws_websubnet2_id}"]
  health_check_type    = "EC2"
}

# LB RELATED #
# Create ALB SG
resource "aws_security_group" "alb" {
  name        = "terraform_alb_security_group"
  description = "Terraform load balancer security group"
  vpc_id      = data.terraform_remote_state.RBAC_NetworkTeam.outputs.aws_vpc_id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = var.alb_sg
  }
}

# Create ALB
resource "aws_alb" "alb" {
  depends_on      = [aws_alb_target_group.group, aws_instance.app_server]
  name            = "terraform-example-alb"
  security_groups = ["${aws_security_group.alb.id}"]
  subnets         = ["${data.terraform_remote_state.RBAC_NetworkTeam.outputs.aws_websubnet1_id}", "${data.terraform_remote_state.RBAC_NetworkTeam.outputs.aws_websubnet2_id}"]
  tags = {
    Name = var.alb_name
  }
}

# Create ALB target group
resource "aws_alb_target_group" "group" {
  depends_on = [aws_vpc.vpc]
  name       = "terraform-example-alb-target"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = data.terraform_remote_state.RBAC_NetworkTeam.outputs.aws_vpc_id
  stickiness {
    type = "lb_cookie"
  }
  # Alter the destination of the health check to be the login page, consider remove.
  health_check {
    path = "/"
    port = 80
  }
}

# Create ALB listener for http
resource "aws_alb_listener" "listener_http" {
  depends_on        = [aws_alb.alb]
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.group.arn
    type             = "forward"
  }
}

output "ip" {
  value = aws_instance.app_server.public_ip
}

output "lb_address" {
  value = aws_alb.alb.dns_name
}

#output "awsaccess" {
#  value = "${data.vault_aws_access_credentials.creds.access_key}"
#}

#output "awssecret" {
#  value = "${data.vault_aws_access_credentials.creds.secret_key}"
#}