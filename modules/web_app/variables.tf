/* This file contains a list of definitions of the web_app module's input variables. */

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

variable "subnets" {
  type        = list(string)
  description = "A list of subnet IDs to attach to the website's ELB."
}

variable "security_groups" {
  type        = list(string)
  description = "A list of security group IDs to assign to the website's ELB."
}

variable "web_app" {
  type        = string
  description = "The name of this website."
}
