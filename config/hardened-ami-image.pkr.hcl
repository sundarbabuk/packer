# This will build a CIS Level 1 hardened AMI from Amazon Linux 2 base AMI

# Validate the template
#   eg: packer validate cis-ami.pkr.hcl 

# Set the correct variables in the variables.json file

# A sample build command would look like this
# packer build -var-file=variables.json cis-ami.pkr.hcl 

# If you don't set the profile variable as above, it will take the following as default
variable "profile" {
  type    = string
  default = "default"
}

# Use the Amazon Linux 2 (latest) AMI as the source_ami
variable "source_ami" {
  type = string
  default ="ami-07e919ac6fefa419f"
}


variable "region" {
  type = string
  default ="us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ami_name_prefix" {
  type    = string
  default = "cis-hardened-ami"
}

# Use the Amazon Linux 2 (latest) AMI as the source_ami
locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")

  standard_tags = {
    BaseOS = "Amazon Linux 2"
  }

}
# Set the VPC and Subnet to somewhat which has Internet accesss (Could be any public subnet)
# Packer will take care of the rest
source "amazon-ebs" "cis-ami" {
  profile                     = "${var.profile}"
  ami_name                    = "${var.ami_name_prefix}-${local.timestamp}"
  instance_type               = "${var.instance_type}"
  region                      = "${var.region}"
  associate_public_ip_address = "true"

  // Amazon Linux 2 AMI ID
  source_ami   = "${var.source_ami}"
  ssh_username = "ubuntu"

  // Set the AMI's Name tag with timestamp
  tag {
    key   = "Name"
    value = "${var.ami_name_prefix}-${local.timestamp}"
  }

  // Set the default tags for the AMI
  dynamic "tag" {
    for_each = local.standard_tags
    content {
      key   = tag.key
      value = tag.value
    }
  }
}

build {
  name = "Hardened AMI Image (CIS)"
  sources = [
    "source.amazon-ebs.cis-ami"
  ]

  provisioner "shell" {
  environment_vars = [
    "FOO=hello world",
  ]
  inline = [
    "echo Installing Redis",
    "sleep 10",
    "sudo apt-get update",
    "sudo apt-get install -y redis-server",
    "echo \"FOO is $FOO\" > example.txt",
  ]
}

  provisioner "shell" {
    inline = [
      "echo Installing AWS Inspector",
      "sleep 10",
      "wget https://inspector-agent.amazonaws.com/linux/latest/install",
      "sudo bash install",
      "rm install",
      ]
    }

  provisioner "shell" {
    inline = [
      "echo Installing Falco",
      "sleep 10",
      "curl -s https://falco.org/repo/falcosecurity-3672BA8F.asc | apt-key add -",
      "echo echo "deb https://download.falco.org/packages/deb stable main" | tee -a /etc/apt/sources.list.d/falcosecurity.list",
      "sudo apt-get update -y",
      "sudo apt-get -y install linux-headers-$(uname -r)",
      "sudo apt-get install -y falco",
      ]
    }
  }

