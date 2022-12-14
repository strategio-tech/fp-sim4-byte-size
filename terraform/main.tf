terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.26.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.0.1"
    }
  }
  required_version = ">= 1.1.0"

  cloud {
    organization = "strategio-byte-size"

    workspaces {
      name = "byte-size-notekeeper"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "random_pet" "sg" {}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web-sg.id]

  user_data =   <<-EOF
                #!/bin/bash
                apt-get update -y
                apt-get -y install python3-pip
                cd ~
                git clone https://github.com/strategio-tech/fp-sim4-byte-size.git
                cd fp-sim4-byte-size
                apt install software-properties-common
                add-apt-repository -y ppa:deadsnakes/ppa
                apt update -y
                apt install python3.8 -y
                pip3 install -t /usr/local/lib/python3.8/dist-packages -r requirements.txt
                python3.8 manage.py
                EOF
}

resource "aws_security_group" "web-sg" {
  name = "${random_pet.sg.id}-sg"
  
  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  // connectivity to ubuntu mirrors is required to run `apt-get update` and `apt-get install apache2`
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}