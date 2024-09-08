variable "instance_name" {
  default = "Jenkins Server" # Names the instance
}

#variable "key_name" {
# default = aws_key_pair.jenkins_key.key_name                  # Names of key in aws
#}
variable "private_key" {
  default = "./jenkins" # file path of private pem key
}

variable "access_key" { # aws access key
}

variable "secret_key" { # aws secret key
}

