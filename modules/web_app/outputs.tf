/* This file contains the output values for the web_app module. */

output "dns_name" {
  value = aws_elb.this.dns_name
}
