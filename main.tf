provider "aws" {
region = "us-east-1"
}


resource "aws_security_group" "instance" {
name= "terraform-example-instance"

ingress{
from_port="${var.server_port}"
to_port = "${var.server_port}"
protocol = "tcp"
cidr_blocks=["0.0.0.0/0"]
}

lifecycle {
create_before_destroy = true
}
}


resource "aws_launch_configuration" "gopal" {
image_id	= "ami-40d28157"
instance_type	= "t2.micro"
security_groups	= ["${aws_security_group.instance.id}"]

user_data = <<-EOF
	    #!/bin/bash
	    echo "Hello World" > index.html
	    nohup busybox httpd -f -p "${var.server_port}" &
	    EOF

lifecycle {

create_before_destroy = true
}

}

variable "server_port" {
description =  "server port number"
default =8080
}


output "elb_dns_name" {
value="${aws_elb.gopal.dns_name}"
}

data "aws_availability_zones" "all" {}

resource "aws_autoscaling_group" "gopal"{
launch_configuration = "${aws_launch_configuration.gopal.id}"
availability_zones = ["${data.aws_availability_zones.all.names}"]
load_balancers= ["${aws_elb.gopal.name}"]
health_check_type = "ELB"
min_size =2
max_size = 10

tag {
key = "Name"
value = "gopal-example-asg"
propagate_at_launch=true
}
}

resource "aws_elb" "gopal"{
name = "gopal-elb"
availability_zones = ["${data.aws_availability_zones.all.names}"]

listener{
lb_port = 80
lb_protocol = "http"
instance_port = "${var.server_port}"
instance_protocol = "http"
}
}

resource "aws_security_group" "elb"
{
name="gopal-elb"
ingress{
from_port = 80
to_port =80
protocol="tcp"
cidr_blocks=["0.0.0.0/0"]
}

egress{
from_port = 0
to_port =0
protocol="-1"
cidr_blocks=["0.0.0.0/0"]
}
}

