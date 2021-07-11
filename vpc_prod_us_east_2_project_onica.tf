/* This is just a simple project to connect to 
an Onica AWS account and plan out initial design
considerations for a virtual private cloud.
 */

variable "whitelist" {
  type = list(string)
}

variable "web_instance_type" {
  type = string
}

variable "web_image_id" {
  type = string
}

variable "web_desired_capacity" {
  type = number
}

variable "web_max_size" {
  type = number
}

variable "web_min_size" {
  type = number
}

variable "web_app" {
  type = string
}

provider "aws" {
  profile                       = "default"
  shared_credentials_file       = "/Users/jgray/terraform/onica/.aws/credentials"
  region                        = "us-east-2"
}

resource "aws_vpc" "simple_web" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name       = "simple_web"
    networking = "terraform"
  }
}

resource "aws_internet_gateway" "sw_igw" { 
    vpc_id =  aws_vpc.simple_web.id
}

resource "aws_subnet" "sw_az1" {
  vpc_id            = aws_vpc.simple_web.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-2a"
  
  tags = {
    networking = "terraform"
  }
}

resource "aws_subnet" "sw_az2" {
  vpc_id            = aws_vpc.simple_web.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2b"
  tags = {
    networking = "terraform"
  }
}

resource "aws_subnet" "sw_az3" {
  vpc_id            = aws_vpc.simple_web.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2c"
  
  tags = {
    networking = "terraform"
  }
}

resource "aws_route_table" "sw_routes" {
  vpc_id = aws_vpc.simple_web.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sw_igw.id
     }
 }

resource "aws_security_group" "simple_web" {
  name 		= "simple_web"
  vpc_id        = aws_vpc.simple_web.id
  description   = "Sets rules to allow HTTP and HTTPS inbound traffic"

  ingress {
    from_port 	= 80
    to_port   	= 80
    protocol  	= "tcp"
    cidr_blocks = var.whitelist
  }

  egress {
    from_port 	= 0
    to_port   	= 0
    protocol  	= "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    networking = "terraform"
  }

}

resource "aws_elb" "simple_web" {
  name            = "simple-web"
  subnets         = [aws_subnet.sw_az1.id, aws_subnet.sw_az2.id, aws_subnet.sw_az3.id]
  security_groups = [aws_security_group.simple_web.id]

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "TCP:80"
    interval            = 30
  }

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  tags = {
    load_balancing = "terraform"
  }

}

resource "aws_launch_template" "simple_web" {
  name_prefix   = "simple-web"
  image_id      = var.web_image_id
  instance_type = var.web_instance_type

  tags = {
    auto_scaling = "terraform"
  }
}

resource "aws_autoscaling_group" "simple_web" {
  vpc_zone_identifier = [aws_subnet.sw_az1.id, aws_subnet.sw_az2.id, aws_subnet.sw_az3.id]
  desired_capacity    = var.web_desired_capacity
  max_size            = var.web_max_size
  min_size            = var.web_min_size

  launch_template {
    id      = aws_launch_template.simple_web.id
    version = "$Latest"
  }

  tag {
    key 		= "auto_scaling"
    value 		= "terraform"
    propagate_at_launch = true
  }

}

resource "aws_autoscaling_attachment" "simple_web" {
  autoscaling_group_name = aws_autoscaling_group.simple_web.id
  elb                    = aws_elb.simple_web.id
}

