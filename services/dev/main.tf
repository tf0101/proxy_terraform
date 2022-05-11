variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "instance_ami" {}
variable "myip" {}
variable "sshkey_path" {}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.5.0"
    }
  }
}

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region  = "ap-northeast-1"
}

data "aws_caller_identity" "self" {}

output "aws_user_id"{
    value ="${data.aws_caller_identity.self.account_id}"
    description = "aws user id"
}

module "myproxy" {
  source  = "../../modules/"
  
  ENV     = "dev"
  VPC_CIDR = "10.10.0.0/16"
  SUBNET_A_CIDR = "10.10.1.0/24"
  SUBNET_C_CIDR = "10.10.2.0/24"
  MYPROXY_AMI ="${var.instance_ami}"
  INSTANSE_TYPE = "t2.micro"
  INGRESS_IP_LIST=[
    {desc="ssh from vpc",from_port=22,to_port=22,protocol="tcp",ip="${var.myip}"},
    {desc="http from vpc",from_port=8118,to_port=8118,protocol="tcp",ip="${var.myip}"},
  ]
  SSH_KEY = file("${var.sshkey_path}") #ssh接続のための公開鍵を指定
}