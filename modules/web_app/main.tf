/* This file contains the main code for the web_app module. */

resource "aws_elb" "this" {
  name 	          = "${var.web_app}-Onica"
  subnets         = var.subnets
  security_groups = var.security_groups

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

resource "aws_launch_template" "this" {
  name_prefix   = "${var.web_app}-Onica"
  image_id      = var.web_image_id
  instance_type = var.web_instance_type

  tags = {
    auto_scaling = "terraform"
  }
}

resource "aws_autoscaling_group" "this" {
  vpc_zone_identifier = var.subnets
  desired_capacity    = var.web_desired_capacity
  max_size            = var.web_max_size
  min_size            = var.web_min_size

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key 		= "auto_scaling"
    value 		= "terraform"
    propagate_at_launch = true
  }

}

resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name = aws_autoscaling_group.this.id
  elb                    = aws_elb.this.id
}

