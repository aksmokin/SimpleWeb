
/* This is a data file containing abstracted IaaC
that works better in variable format.
 */

web_image_id      	= "ami-0fd02a3bc174c9398"
web_instance_type 	= "t2.micro"
whitelist 		= ["0.0.0.0/0"]
web_desired_capacity   	= 2
web_max_size           	= 3
web_min_size           	= 1
web_app 		= "SimpleWeb"
