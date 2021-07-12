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

data "template_file" "user_data_hw" {
  template = <<EOF
#! /bin/bash
sudo yum update
sudo yum install -y httpd
sudo chkconfig httpd on
sudo service httpd start
sudo rm /opt/bitnami/nginx/html/index.html
echo "<?php echo '<!DOCTYPE html PUBLIC \'-//W3C//DTD XHTML 1.0 Transitional//EN\' 
\'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\'>
<html xmlns=\'http://www.w3.org/1999/xhtml\' lang=\'en\' xml:lang=\'en\'>
<head>
<meta http-equiv=\'Content-Type\' content=\'text/html; charset=iso-8859-1\' />
<title>Hello From AWS!</title>
<style type=\'text/css\'>
body{ 
margin: 0; 
padding: 0; 
border: 0; 
overflow: hidden; 
height: 100%; 
max-height: 100%; 
} 
 
#framecontentLeft, #framecontentRight{ 
position: absolute; 
top: 0; 
left: 0; 
width: 400px; 
height: 100%; 
overflow: hidden; 
background-color: #9C9A9C; 
color: white; 
} 
 
#framecontentRight{ 
left: auto; 
right: 0; 
width: 400px; 
overflow: hidden; 
background-color: #9C9A9C; 
color: white; 
} 
 
#framecontentBottom{ 
position: absolute; 
bottom: 0; 
left: 400px; 
right: 400px; 
width: auto; 
height: 400px; 
overflow: hidden; 
background-color: #9C9A9C; 
color: white; 
} 
 
#maincontent{ 
position: fixed;  
top: 0; 
bottom: 400px; 
left: 400px; 
right: 400px; 
overflow: auto; 
background: #fff;
} 
 
.innertube{ 
margin: 15px; 
} 
 
* html body{ 
padding: 0 400px 400px 400px; 
} 
 
* html #maincontent{ 
height: 100%; 
width: 100%; 
} 
 
* html #framecontentBottom{ 
width: 100%; 
text-align: center; 
} 
 
</style> 
<style> 
.hn { 
position:relative; 
font-style: oblique; 
font-size: large; 
font-family: Helvetica; 
text-align: center; 
}

.githubBtn {
box-shadow:inset 0px 1px 0px 0px #ffffff;
background:linear-gradient(to bottom, #f9f9f9 5%, #e9e9e9 100%);
background-color:#f9f9f9;
border-radius:6px;
border:1px solid #dcdcdc;
display:inline-block;
cursor:pointer;
color:#666666;
font-family:Verdana;
font-size:25px;
font-weight:bold;
padding:12px 24px;
text-decoration:none;
text-shadow:0px 1px 0px #ffffff;
}

.githubBtn:hover {
background:linear-gradient(to bottom, #e9e9e9 5%, #f9f9f9 100%);
background-color:#e9e9e9;
}

.githubBtn:active {
position:relative;
top:1px;
}
 
.copy { 
position:relative; 
font-style: italic; 
font-size: large; 
font-family: Helvetica; 
text-align: center; 
} 
 
.copyright { 
position:relative; 
width: 100%;
display: block;
margin: auto;
font-style: normal; 
font-size: medium; 
font-family: Helvetica; 
text-align: center; 
} 
</style> 
 
</head> 
 
<body> 
 
<div id=\'framecontentLeft\'></div> 
 
<div id=\'framecontentRight\'></div> 
 
<div id=\'framecontentBottom\'>
<div class=\'innertube\'> 
<span class=\'copyright\'>Copyright &copy; 2021 by Justin K. Grayman</span>
</div> 
</div> 
<div id=\'maincontent\'> 
<div class=\'innertube\'> 
<h1 style=\'text-align: center; font-family:Helvetica;\'>Hello World!</h1> 
<span class=\'copy\'><p>This greeting is from</p></span> 
<span class=\'hn\'><p>'.gethostname().'</p></span> 
<br/>
<br/>
<br/>
<br/>
<center><a href=\'https://github.com/graymanj/onicatest\' target=\'_blank\' class=\'githubBtn\'>View on GitHub</a></center>
</div> 
</div> 
</body> 
</html>' 
?>" | sudo tee /opt/bitnami/nginx/html/index.php
EOF
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.web_app}-Onica"
  image_id      = var.web_image_id
  instance_type = var.web_instance_type
  vpc_security_group_ids = var.security_groups

  tags = {
    auto_scaling = "terraform"
  }

  user_data = "${base64encode(data.template_file.user_data_hw.rendered)}"
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

resource "aws_autoscalingplans_scaling_plan" "this" {
  name = "simple-web-autoscaling-plan"

  application_source {
    tag_filter {
      key    = "auto_scaling"
      values = ["terraform"]
    }
  }

  scaling_instruction {
    max_capacity       = var.web_max_size
    min_capacity       = var.web_min_size
    resource_id        = format("autoScalingGroup/%s", aws_autoscaling_group.this.name)
    scalable_dimension = "autoscaling:autoScalingGroup:DesiredCapacity"
    service_namespace  = "autoscaling"

    target_tracking_configuration {
      predefined_scaling_metric_specification {
        predefined_scaling_metric_type = "ASGAverageCPUUtilization"
      }

      target_value = var.web_target_value
    }
  }
}

resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name = aws_autoscaling_group.this.id
  elb                    = aws_elb.this.id
}

