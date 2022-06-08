# myproxy terraform
## Description
Automated construction of proxy server infrastructure using terraform  
The following configuration will be used, but only one instance will actually be launched (due to the free quota)  

![proxy drawio](https://user-images.githubusercontent.com/35088230/172534113-9d0ccae2-90cc-4075-bb83-993d77a8b744.png)

## What you need

Requires an aws account  

Use tfenv to deploy terraform  
```bash
brew install tfenv
tfenv install 1.1.9
```

```bash
brew install ansible
```

```bash
git clone https://github.com/tf0101/proxy_terraform.git
```


## Setup
Creating credentialed files  

```bash
# services/prod/
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
A self-made image created on aws or the default ec2 image (ami-02c3627b04781eada)

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
# services/prod/
mkdir ssh-key
cd ssh-key
ssh-keygen -t rsa -f rsa_key_ec2
```

・Specify public key file path  
In this case sshkey_path = ". /ssh-key/rsa_key_ec2.pub".  


## Resource Building

```bash
# services/prod/
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

## ansible playbook
Set up tor and privoxy with ansible  

User→privoxy→tor→Internet  
Create a pathway called  

### EC2 IP set
Get the IP of the EC2 created by terraform and write it to the following file  

```
# ansible/inventory/production

[targethost]
<server IP >
```

The IP address of the EC2 created by terraform is listed in the following file generated when the resource is created  
```
services/prod/terraform.tfstate
```

### Setup tor & privoxy
Set up tor and privoxy with the following command  
```bash
# ansible/
ansible-playbook site.yml
```

### operation check
```bash
curl --proxy http://<ec2 server ip>:8118 http://ipinfo.io
```
If an IP different from the EC2 IP address is displayed, OK  

## Resource deletion
If you want to delete all resources, execute the following command in the target directory  
```bash
# services/prod/
terraform destroy
```

## If you want to tinker with tor or privoxy settings
Just rewrite the contents of the file in the following path  

### tor
ansible/roles/tor/files/torrc  

### privoxy
ansible/roles/privoxy/files/config  
