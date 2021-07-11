/* This is just a simple project to connect to 
an Onica AWS account and plan out initial design
considerations for a virtual private cloud.
 */

provider "aws" {
  profile                       = "default"
  shared_credentials_file       = "/Users/jgray/terraform/onica/.aws/credentials"
  region                        = "us-east-2"
}


resource "aws_vpc" "simple_web" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "simple_web"
    networking = "terraform"
  }
}

resource "aws_security_group" "simple_web" {
  name 		= "simple_web"
  description   = "Sets rules to allow HTTP and HTTPS inbound traffic"

  ingress {
    from_port 	= 80
    to_port   	= 80
    protocol  	= "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port 	= 443
    to_port   	= 443
    protocol  	= "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
