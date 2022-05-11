variable ENV {
  type = string
  description = "環境(prod/dev)"
  default = "dev"
}

variable VPC_CIDR {
  type = string
  description = "VPCのCIDR"
  default = "10.0.0.0/16"
}

variable SUBNET_A_CIDR {
  type = string
  description = "subnet aのCIDR"
  default = "10.0.1.0/24"
}

variable SUBNET_C_CIDR {
  type = string
  description = "subnet cのCIDR"
  default = "10.0.2.0/24"
}

variable "MYPROXY_AMI" {
  type = string
  description = "myproxy ami"
  default = ""
}

variable "INSTANSE_TYPE" {
  type = string
  description = "instanse type"
  default = "t2.micro"
}

variable "INGRESS_IP_LIST" {
  type = list(object({
    desc = string
    from_port = number
    to_port = number
    protocol = string
    ip = string
  }))
  description = "ingress ip list"
  default = []
}

variable "SSH_KEY" {
  type = string
  description = "ssh-key"
  default = ""
}