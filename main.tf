terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "local" {
  # Configuration options
}

provider "null" {
  # Configuration options
}

provider "random" {
  # Configuration options
}

resource "random_integer" "subentnum" {
  min = 0
  max = 1
}

locals {
  UserName       = substr("${var.instance_name}", 0, 4)
  CVMname        = "${local.UserName}AWSCVM"
  LVMname        = "${local.UserName}AWSLVM"
  KeyPair        = var.MachineType ? var.key_name_developer : var.key_name_supportteam
  SecurityGroups = var.MachineType ? var.security_groups_developer : var.security_groups_supportteam
  subnetID       = var.MachineType ? var.subnet_id_developer[random_integer.subentnum.result] : var.subnet_id_supportteam[random_integer.subentnum.result]
}

data "template_file" "userdata"{
  template = <<EOF
<powershell>
set-netconnectionprofile -networkcategory private
tzutil /s "Eastern Standard Time"
$hostIP=(Get-NetAdapter| Get-NetIPAddress).IPv4Address|Out-String
$hostname = $env:COMPUTERNAME
$srvCert = New-SelfSignedCertificate -DnsName $hostname,$hostIP -CertStoreLocation Cert:\LocalMachine\My
New-Item -Path WSMan:\localhost\Listener\ -Transport HTTPS -Address * -CertificateThumbPrint $srvCert.Thumbprint -Force
New-NetFirewallRule -DisplayName "Allow WinRM HTTPS" -Direction Inbound -LocalPort 5986 -Protocol TCP -Action Allow
</powershell>
EOF
}

resource "aws_instance" "ec2_instance" {
  ami                         = var.AMI
  instance_type               = var.instance_type
  security_groups             = local.SecurityGroups
  associate_public_ip_address = false
  key_name                    = local.KeyPair
  subnet_id                   = local.subnetID
  get_password_data           = var.LinuxMachine ? "false" : "true"
  tags = {
    Name = var.LinuxMachine ? local.LVMname : local.CVMname
    UserName = var.instance_name
  }
  user_data = var.WindowsMachine ? data.template_file.userdata.rendered : null

  root_block_device {
    volume_size = var.LinuxMachine ? 150 : 100
    volume_type = "gp3"
    encrypted   = true
  }
}

# Retrives windows password
resource "null_resource" "AdminPass" {
  triggers = {
    admin_pass = var.LinuxMachine ? null : "${rsadecrypt(aws_instance.ec2_instance.password_data, file("${var.temp_directory}/${local.KeyPair}"))}"
  }

  provisioner "local-exec" {
    command = "echo 'Running RSA decryption...'"
  }
  depends_on = [
    aws_instance.ec2_instance
  ]
}

#This part is a output variable for the terraform script
output "PrivateIP" {
  value     = aws_instance.ec2_instance.private_ip
  sensitive = true
}
#Second output var for username
output "UserName" {
  value = var.instance_name
}
#Value of the Linux instance name
output "LVMname" {
  value = local.LVMname
}
#Value of the Windows instance name
output "CVMname" {
  value = local.CVMname
}
#Windows machine admin password
output "AdminPass" {
  value     = null_resource.AdminPass.triggers.admin_pass
  sensitive = true
}

resource "null_resource" "removefromtfstate" {
  provisioner "local-exec" {
    command = "terraform state rm aws_instance.ec2_instance"
  }
  depends_on = [
    aws_instance.ec2_instance
  ]
}