provider "aws" {
region = "us-east-1"
}

resource "aws_db_instance" "gopal-mysql"{
	engine	= "mysql"
	allocated_storage= 10
	instance_class	= "db.t2_micro"
	name = "gopal-mysql-db"
	username = "admin"
	password = "${var.db_password}"
}

