/* This is just a simple project to connect to 
an Onica AWS account and plan out initial design
considerations for a virtual private cloud.
 */

variable "whitelist" {
  type        = list(string)
  description = "List of CIDR blocks whitelisted by security group ingress rules."
}

variable "web_instance_type" {
  type        = string
  description = "The type of the instance."
}

variable "web_image_id" {
  type        = string
  description = "The id of the machine image (AMI) to use for the website's server."
}

variable "web_desired_capacity" {
  type        = number
  description = "The number of Amazon EC2 instances that should be running in the website's Auto Scaling Group."
}

variable "web_max_size" {
  type        = number
  description = "The maximum size of the website's Auto Scaling Group."
}

variable "web_min_size" {
  type        = number
  description = "The minimum size of the website's Auto Scaling Group."
}

variable "web_target_value" {
  type        = number
  description = "The target value for a scaling metric."
}

variable "web_app" {
  type        = string
  description = "The name of this website."
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

resource "aws_main_route_table_association" "sw_mrta" {
  vpc_id         = aws_vpc.simple_web.id
  route_table_id = aws_route_table.sw_routes.id
}

resource "aws_route_table_association" "sw_rta1" {
  subnet_id      = aws_subnet.sw_az1.id
  route_table_id = aws_route_table.sw_routes.id
}

resource "aws_route_table_association" "sw_rta2" {
  subnet_id      = aws_subnet.sw_az2.id
  route_table_id = aws_route_table.sw_routes.id
}

resource "aws_route_table_association" "sw_rta3" {
  subnet_id      = aws_subnet.sw_az3.id
  route_table_id = aws_route_table.sw_routes.id
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

module "web_app" {
  source = "./modules/web_app"

  web_instance_type     = var.web_instance_type
  web_image_id          = var.web_image_id
  web_desired_capacity  = var.web_desired_capacity
  web_max_size          = var.web_max_size
  web_min_size          = var.web_min_size
  web_target_value      = var.web_target_value
  subnets               = [aws_subnet.sw_az1.id,aws_subnet.sw_az2.id,aws_subnet.sw_az3.id]
  security_groups       = [aws_security_group.simple_web.id]
  web_app               = var.web_app
}
