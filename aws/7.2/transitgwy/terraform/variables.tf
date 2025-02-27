##############################################################################################################
#
# FortiGate Terraform deployment
# Active Passive High Availability MultiAZ with AWS Transit Gateway with VPC standard attachment -
#
##############################################################################################################

# Access and secret keys to your environment
variable "access_key" {}
variable "secret_key" {}

# Prefix for all resources created for this deployment in AWS
variable "tag_name_prefix" {
  description = "Provide a common tag prefix value that will be used in the name tag for all resources"
  default     = "TGW"
}

variable "tag_name_unique" {
  description = "Provide a unique tag prefix value that will be used in the name tag for each modules resources"
  default     = "terraform"
}

// License Type to create FortiGate-VM
// Provide the license type for FortiGate-VM Instances, either byol or payg.
variable "license_type" {
  default = "byol"
}

// license file for the active fgt
variable "license" {
  // Change to your own byol license file, license.lic
  type    = string
  default = "license.txt"
}

// license file for the passive fgt
variable "license2" {
  // Change to your own byol license file, license2.lic
  type    = string
  default = "license2.txt"
}

#############################################################################################################
#  AMI

// AMIs are for FGTVM-AWS(PAYG) - 7.2.0
variable "fgt-ond-amis" {
  type = map(any)
  default = {
    us-east-1      = "ami-035a7ca1d22b2ac60"
    us-east-2      = "ami-0c89751940e00028a"
    us-west-1      = "ami-027023effe0d0cbcb"
    us-west-2      = "ami-0e18da7f57b1455de"
    af-south-1     = "ami-0020b49aee42aac43"
    ap-east-1      = "ami-040df30827808387e"
    ap-southeast-3 = "ami-08b193fa0e26053bc"
    ap-south-1     = "ami-03ce0208e1bf0a4c2"
    ap-northeast-3 = "ami-0dba0e863219fbd2c"
    ap-northeast-2 = "ami-01966ce84e55ce9af"
    ap-southeast-1 = "ami-0abcebf6fa84ec1c9"
    ap-southeast-2 = "ami-0d4a09cac89f2cb2b"
    ap-northeast-1 = "ami-08e9a008d439bd92d"
    ca-central-1   = "ami-0f575e9fe174cc613"
    eu-central-1   = "ami-09b319a3f356c62a3"
    eu-west-1      = "ami-0295b18e7c5c68440"
    eu-west-2      = "ami-0e0cf6ee5949311d3"
    eu-south-1     = "ami-00c0fd80460334680"
    eu-west-3      = "ami-0a2f70eeaccb4f756"
    eu-north-1     = "ami-0980a6c5462eb20c7"
    me-south-1     = "ami-0e971c7104d9ab577"
    sa-east-1      = "ami-0f857d7ef57d996d7"
 }
}


// AMIs are for FGTVM AWS(BYOL) - 7.2.0
variable "fgtvmbyolami" {
  type = map(any)
  default = {
    us-east-1      = "ami-08a9244de2d3b3cfa"
    us-east-2      = "ami-0b07d15df1781b3d8"
    us-west-1      = "ami-02dc2d7ea094493d6"
    us-west-2      = "ami-0c0dcf7b73b82c9b1"
    af-south-1     = "ami-0d74ee5597e3ef661"
    ap-east-1      = "ami-0a0c5c6454847d23a"
    ap-southeast-3 = "ami-028cc9519f272bcb6"
    ap-south-1     = "ami-085942a3a94223f47"
    ap-northeast-3 = "ami-09b93acca6bd3596c"
    ap-northeast-2 = "ami-0cf302c5443f1ebb0"
    ap-southeast-1 = "ami-0a766a36e6c0b330e"
    ap-southeast-2 = "ami-0b658e3ca1fc97423"
    ap-northeast-1 = "ami-0daa2ffa06df3702f"
    ca-central-1   = "ami-07f812bb597b8c317"
    eu-central-1   = "ami-0d049e761ea8dbffc"
    eu-west-1      = "ami-0caa0716272a43357"
    eu-west-2      = "ami-09dc1af4df14fd469"
    eu-south-1     = "ami-0767c696d9d0d5f9f"
    eu-west-3      = "ami-0820c09066de0e77e"
    eu-north-1     = "ami-06828be5bef414e7d"
    me-south-1     = "ami-054c0c3be39202670"
    sa-east-1      = "ami-07fe117d69adc5f80"
  }
}

variable "scenario" {
  default = "ha-tgw"
}

// password for FortiGate HA configuration
variable "password" {
  default = "fortinet"
}
# References of your environment
variable "region" {
  description = "Provide the region to deploy the VPC in"
  default     = "eu-west-1"
}

variable "availability_zone1" {
  description = "Provide the first availability zone to create the subnets in"
  default     = "eu-west-1a"
}

variable "availability_zone2" {
  description = "Provide the second availability zone to create the subnets in"
  default     = "eu-west-1c"
}

# References to your Networks
# security VPC
variable "security_vpc_cidr" {
  description = "Provide the network CIDR for the VPC"
  default     = "10.0.0.0/16"
}

#### data subnets
variable "security_vpc_data_subnet_cidr1" {
  description = "Provide the network CIDR for the data subnet1 in security vpc"
  default     = "10.0.1.0/24"
}

variable "security_vpc_data_gw1" {
  description = "Provide the default local router IP for the subnet1"
  default     = "10.0.1.1/24"
}

variable "security_vpc_data_subnet_cidr2" {
  description = "Provide the network CIDR for the data subnet1 in security vpc"
  default     = "10.0.10.0/24"
}

variable "security_vpc_data_gw2" {
  description = "Provide the default local router IP for the subnet2"
  default     = "10.0.10.1/24"
}

#### relay subnets
variable "security_vpc_relay_subnet_cidr1" {
  description = "Provide the network CIDR for the relay subnet1 in security vpc"
  default     = "10.0.101.0/24"
}

variable "security_vpc_relay_subnet_cidr2" {
  description = "Provide the network CIDR for the relay subnet2 in security vpc"
  default     = "10.0.102.0/24"
}

#### mgmt subnets
variable "security_vpc_mgmt_subnet_cidr1" {
  description = "Provide the network CIDR for the mgmt subnet1 in security vpc"
  default     = "10.0.4.0/24"
}

variable "security_vpc_mgmt_subnet1_gw" {
  description = "Provide the default local router IP for the subnet1"
  default     = "10.0.4.1/24"
}

variable "security_vpc_mgmt_subnet_cidr2" {
  description = "Provide the network CIDR for the mgmt subnet2 in security vpc"
  default     = "10.0.40.0/24"
}

variable "security_vpc_mgmt_subnet2_gw" {
  description = "Provide the default local router IP for the subnet2"
  default     = "10.0.40.1/24"
}

#### Heartbeat subnets
variable "security_vpc_heartbeat_subnet_cidr1" {
  description = "Provide the network CIDR for the public subnet1 in security vpc"
  default     = "10.0.3.0/24"
}

variable "security_vpc_heartbeat_subnet_cidr2" {
  description = "Provide the network CIDR for the public subnet1 in security vpc"
  default     = "10.0.30.0/24"
}

# spoke1 VPC
variable "spoke_vpc1_cidr" {
  description = "Provide the network CIDR for the VPC"
  default     = "10.1.0.0/16"
}

variable "spoke_vpc1_private_subnet_cidr1" {
  description = "Provide the network CIDR for the private subnet1 in spoke vpc1"
  default     = "10.1.1.0/24"
}

variable "spoke_vpc1_private_subnet_cidr2" {
  description = "Provide the network CIDR for the private subnet2 in spoke vpc1"
  default     = "10.1.10.0/24"
}

# spoke2 VPC
variable "spoke_vpc2_cidr" {
  description = "Provide the network CIDR for the VPC"
  default     = "10.2.0.0/16"
}

variable "spoke_vpc2_private_subnet_cidr1" {
  description = "Provide the network CIDR for the private subnet1 in spoke vpc2"
  default     = "10.2.1.0/24"
}

variable "spoke_vpc2_private_subnet_cidr2" {
  description = "Provide the network CIDR for the private subnet2 in spoke vpc2"
  default     = "10.2.10.0/24"
}

# Mgmt VPC
variable "mgmt_cidr" {
  description = "Provide the network CIDR for the Mgmt VPC"
  default     = "10.3.0.0/16"
}

variable "mgmt_private_subnet_cidr1" {
  description = "Provide the network CIDR for the mgmt subnet1 in spoke mgmt"
  default     = "10.3.1.0/24"
}

variable "mgmt_private_subnet_cidr2" {
  description = "Provide the network CIDR for the mgmt subnet2 in spoke mgmt"
  default     = "10.3.10.0/24"
}

# References to your FortiGate
variable "ami" {
  description = "Provide an AMI for the FortiGate instances"
  default     = "automatically gathered by terraform modules"
}

variable "instance_type" {
  description = "Provide the instance type for the FortiGate instances"
  default     = "c5.xlarge"
}

variable "keypair" {
  description = "Provide a keypair for accessing the FortiGate instances"
  default     = "<AWS SSH KEY>"
}

variable "cidr_for_access" {
  description = "Provide a network CIDR for accessing the FortiGate instances"
  default     = "0.0.0.0/0"
}
