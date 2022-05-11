resource "aws_vpc" "myproxy_vpc" {
  cidr_block                       = var.VPC_CIDR # VPCに設定したいCIDRを指定
  enable_dns_support               = "true" # VPC内でDNSによる名前解決を有効化するかを指定
  enable_dns_hostnames             = "true" # VPC内インスタンスがDNSホスト名を取得するかを指定
  instance_tenancy                 = "default" # VPC内インスタンスのテナント属性を指定
  assign_generated_ipv6_cidr_block = "false" # IPv6を有効化するかを指定

  tags = {
    Name  = "myproxy_vpc_${var.ENV}"
    Env = var.ENV
  }
}

resource "aws_subnet" "myproxy_subnet_a" {
  vpc_id                          = aws_vpc.myproxy_vpc.id # VPCのIDを指定
  cidr_block                      = var.SUBNET_A_CIDR # サブネットに設定したいCIDRを指定
  assign_ipv6_address_on_creation = "false" # IPv6を利用するかどうかを指定
  map_public_ip_on_launch         = "true" # VPC内インスタンスにパブリックIPアドレスを付与するかを指定
  availability_zone               = "ap-northeast-1a" # サブネットが稼働するAZを指定

  tags = {
    Name = "myproxy_subnet_${var.ENV}_1a"
    Env = var.ENV
  }
}

resource "aws_subnet" "myproxy_subnet_c" {
  vpc_id                          = aws_vpc.myproxy_vpc.id
  cidr_block                      = var.SUBNET_C_CIDR
  assign_ipv6_address_on_creation = "false"
  map_public_ip_on_launch         = "true"
  availability_zone               = "ap-northeast-1c"

  tags = {
      Name = "myproxy_subnet_${var.ENV}_1c"
      Env = var.ENV
  }
}

resource "aws_internet_gateway" "myproxy_igw" {
  vpc_id = aws_vpc.myproxy_vpc.id # VPCのIDを指定

  tags = {
    Name  = "myproxy_igw_${var.ENV}"
    Env = var.ENV
  }
}

resource "aws_route_table" "myproxy_rt" {
  vpc_id = aws_vpc.myproxy_vpc.id # VPCのIDを指定

  # 外部向け通信を可能にするためのルート設定
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myproxy_igw.id
  }

  tags = {
    Name  = "myproxy_rt_${var.ENV}"
    Env = var.ENV
  }
}

resource "aws_main_route_table_association" "myproxy_rt_vpc" {
  vpc_id         = aws_vpc.myproxy_vpc.id # 紐づけたいVPCのIDを指定
  route_table_id = aws_route_table.myproxy_rt.id # 紐付けたいルートテーブルのIDを指定
}

resource "aws_route_table_association" "myproxy_rt_subet_a" {
  subnet_id      = aws_subnet.myproxy_subnet_a.id # 紐づけたいサブネットのIDを指定
  route_table_id = aws_route_table.myproxy_rt.id # 紐付けたいルートテーブルのIDを指定
}

resource "aws_route_table_association" "myproxy_rt_subnet_c" {
  subnet_id      = aws_subnet.myproxy_subnet_c.id
  route_table_id = aws_route_table.myproxy_rt.id
}

locals {
  ingress_list=var.INGRESS_IP_LIST
}

resource "aws_security_group" "admin" {
    name = "admin"
    description = "sg white list"
    vpc_id = aws_vpc.myproxy_vpc.id

    dynamic "ingress" {
      for_each = local.ingress_list
      content {
        description = ingress.value.desc
        from_port   = ingress.value.from_port
        to_port     = ingress.value.to_port
        protocol    = ingress.value.protocol
        cidr_blocks = [ingress.value.ip]
      }
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name  = "myproxy_sg_${var.ENV}"
      Env = var.ENV
    }
}

resource "aws_instance" "myproxy" {
    ami = var.MYPROXY_AMI
    instance_type = var.INSTANSE_TYPE
    vpc_security_group_ids = [
      aws_security_group.admin.id
    ]
    subnet_id = aws_subnet.myproxy_subnet_a.id
    associate_public_ip_address = "true"
    key_name = aws_key_pair.ssh-key.id

    tags = {
      Name  = "myproxy_instance_${var.ENV}"
      Env = var.ENV
    }
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "ssh-key"
  public_key = var.SSH_KEY
}