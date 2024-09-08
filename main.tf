terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_security_group" "jenkins_sg"{
name = "jenkins-sg"
description = "jenkins security group"


dynamic "ingress" {
for_each = [80, 22, 8080, 443]
iterator = port

content {
description = "jenkins port allowing"
from_port = port.value
to_port = port.value
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
}

dynamic "egress" {
for_each = [80, 22, 443]
iterator = port

content {
description = "jenkins port allowing"
from_port = port.value
to_port = port.value
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
}

}

resource "aws_key_pair" "jenkins_key" {
  key_name   = "jenkins"
  public_key = file("${path.module}/jenkins.pub")
}

resource "aws_instance" "Jenkins_server" {
  ami             = "ami-0c7217cdde317cfec"
  instance_type   = "t2.medium"
  security_groups = ["${aws_security_group.jenkins_sg.name}"]
  key_name        = aws_key_pair.jenkins_key.key_name
  tags = {
    Name : var.instance_name
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key)
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sleep 5",
      "sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key",
      "echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install fontconfig openjdk-17-jre -y",
      "sleep 5",
      "sudo apt-get install jenkins -y",
      "sleep 5",
      "sudo echo 'The initial admin password is: '; sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
    ]
  }
}
