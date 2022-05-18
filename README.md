# myproxy terraform
## Description
Automated construction of proxy server infrastructure using terraform
The following configuration will be used, but only one instance will actually be launched (due to the free quota)
![proxy netimg drawio](https://user-images.githubusercontent.com/35088230/169131723-06b0b2c9-4d9e-4a61-878e-73e28ef4cdd9.png)


## Setup
Creating credentialed files

```bash
cd ./prod/
touch terraform.tfvars
```

Write the necessary information in the credential file

```
#terraform.tfvars

aws_access_key = ""
aws_secret_key = ""
instance_ami = ""
myip = ""
sshkey_path = ""
```
### terraform.tfvars
#### aws token
Create an access token in aws "aws_access_key" and "aws_secret_key

#### instance ami
Specify the id of the created ami (put in OSS such as squid and configure the daemon at startup using systemctl, etc.)

#### myip
Specify IPs to allow access in the whitelist (e.g., your IP)
For more information, see the following section of main.tf
Set up a white list by passing to INGRESS_IP_LIST an object of IPs that are allowed to communicate in the following format

```
#main.tf

module "myproxy" {
  
  INSTANSE_TYPE = "t2.micro"
  INGRESS_IP_LIST=[
    {desc="ssh from vpc",from_port=22,to_port=22,protocol="tcp",ip="${var.myip}"},
    {desc="http from vpc",from_port=8118,to_port=8118,protocol="tcp",ip="${var.myip}"},
  ]
  SSH_KEY = file("${var.sshkey_path}")
}
```

#### sshkey_path
Specify the file path of the public key generated for ssh access to ec2
・Creating ssh-key file
Create public-private key pairs with ssh-keygen
The following command creates a public key and a private key under the ssh-key directory.
```bash
cd ./prod/
mkdir ssh-key
cd ssh-key
ssh-keygen -t rsa -f rsa_key_ec2
```

・Specify public key file path
In this case sshkey_path = ". /ssh-key/rsa_key_ec2.pub".


## construction

```bash
terraform init
terraform paln
terraform apply
```

### init
```bash
terraform init
```

### Configuration Confirmation
```bash
terraform plan
```

### Construction
```bash
terraform apply
```

### Confirmation of deletion
```bash
terraform plan -destroy
```

### Construct Deletion
```bash
terraform destroy
```

## Generated EC2 IP
The IP of the EC2 you created is written somewhere in terraform.tfstate