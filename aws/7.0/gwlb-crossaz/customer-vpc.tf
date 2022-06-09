// AWS VPC - Customer
resource "aws_vpc" "customer-vpc" {
  cidr_block           = var.csvpccidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_classiclink   = false
  instance_tenancy     = "default"
  tags = {
    Name = "terraform customer demo"
  }
}

resource "aws_subnet" "cspublicsubnetaz1" {
  vpc_id            = aws_vpc.customer-vpc.id
  cidr_block        = var.cspubliccidraz1
  availability_zone = var.az1
  tags = {
    Name = "cs public subnet az1"
  }
}

resource "aws_subnet" "csprivatesubnetaz1" {
  vpc_id            = aws_vpc.customer-vpc.id
  cidr_block        = var.csprivatecidraz1
  availability_zone = var.az1
  tags = {
    Name = "cs private subnet az1"
  }
}

resource "aws_subnet" "cspublicsubnetaz2" {
  vpc_id            = aws_vpc.customer-vpc.id
  cidr_block        = var.cspubliccidraz2
  availability_zone = var.az2
  tags = {
    Name = "cs public subnet az2"
  }
}

resource "aws_subnet" "csprivatesubnetaz2" {
  vpc_id            = aws_vpc.customer-vpc.id
  cidr_block        = var.csprivatecidraz2
  availability_zone = var.az2
  tags = {
    Name = "cs private subnet az2"
  }
}


resource "aws_internet_gateway" "csigw" {
  vpc_id = aws_vpc.customer-vpc.id
  tags = {
    Name = "cs-igw"
  }
}


resource "aws_route_table" "csingressrt" {
  vpc_id = aws_vpc.customer-vpc.id

  tags = {
    Name = "cs-public-edge-rt"
  }
}

resource "aws_route_table" "cspublicrt" {
  vpc_id = aws_vpc.customer-vpc.id

  tags = {
    Name = "cs-public-egress-rt"
  }
}

resource "aws_route_table" "csprivatert" {
  depends_on = [aws_vpc_endpoint.gwlbendpoint]
  vpc_id     = aws_vpc.customer-vpc.id

  tags = {
    Name = "cs-private-rt"
  }
}

resource "aws_route_table" "csprivatert2" {
  depends_on = [aws_vpc_endpoint.gwlbendpoint2]
  vpc_id     = aws_vpc.customer-vpc.id

  tags = {
    Name = "cs-private-rt2"
  }
}

resource "aws_route" "csingressroute1" {
  depends_on             = [aws_route_table.csingressrt]
  route_table_id         = aws_route_table.csingressrt.id
  destination_cidr_block = var.csprivatecidraz1
  vpc_endpoint_id        = aws_vpc_endpoint.gwlbendpoint.id
}

resource "aws_route" "csingressroute2" {
  depends_on             = [aws_route_table.csingressrt]
  route_table_id         = aws_route_table.csingressrt.id
  destination_cidr_block = var.csprivatecidraz2
  vpc_endpoint_id        = aws_vpc_endpoint.gwlbendpoint2.id
}

resource "aws_route" "csinternalroute" {
  depends_on             = [aws_route_table.csprivatert]
  route_table_id         = aws_route_table.csprivatert.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = aws_vpc_endpoint.gwlbendpoint.id
}

resource "aws_route" "csinternalroute2" {
  depends_on             = [aws_route_table.csprivatert2]
  route_table_id         = aws_route_table.csprivatert2.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = aws_vpc_endpoint.gwlbendpoint2.id
}

resource "aws_route" "csexternalroute" {
  depends_on             = [aws_route_table.cspublicrt]
  route_table_id         = aws_route_table.cspublicrt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.csigw.id
}


resource "aws_route_table_association" "cspublicassociate" {
  route_table_id = aws_route_table.csingressrt.id
  gateway_id     = aws_internet_gateway.csigw.id
}

resource "aws_route_table_association" "csinternalassociateaz1" {
  subnet_id      = aws_subnet.csprivatesubnetaz1.id
  route_table_id = aws_route_table.csprivatert.id
}

resource "aws_route_table_association" "csinternalassociateaz2" {
  subnet_id      = aws_subnet.csprivatesubnetaz2.id
  route_table_id = aws_route_table.csprivatert2.id
}

resource "aws_route_table_association" "csexternalassociateaz1" {
  subnet_id      = aws_subnet.cspublicsubnetaz1.id
  route_table_id = aws_route_table.cspublicrt.id
}

resource "aws_route_table_association" "csexternalassociateaz2" {
  subnet_id      = aws_subnet.cspublicsubnetaz2.id
  route_table_id = aws_route_table.cspublicrt.id
}


resource "aws_vpc_endpoint" "gwlbendpoint" {
  service_name      = aws_vpc_endpoint_service.fgtgwlbservice.service_name
  subnet_ids        = [aws_subnet.cspublicsubnetaz1.id]
  vpc_endpoint_type = aws_vpc_endpoint_service.fgtgwlbservice.service_type
  vpc_id            = aws_vpc.customer-vpc.id
}

resource "aws_vpc_endpoint" "gwlbendpoint2" {
  service_name      = aws_vpc_endpoint_service.fgtgwlbservice.service_name
  subnet_ids        = [aws_subnet.cspublicsubnetaz2.id]
  vpc_endpoint_type = aws_vpc_endpoint_service.fgtgwlbservice.service_type
  vpc_id            = aws_vpc.customer-vpc.id
}

// Simple website
resource "aws_instance" "web" {
  ami             = "${data.aws_ami.amazon-linux-2.id}"
  instance_type   = "t3.micro"
  key_name        = var.keyname
  subnet_id       = aws_subnet.csprivatesubnetaz1.id
  security_groups = [aws_security_group.sg.id]
  associate_public_ip_address = true
  
  user_data     = <<-EOF
                  #!/bin/bash
                  sudo su
                  yum -y install httpd
                  sudo systemctl enable httpd
                  sudo systemctl start httpd
                  EOF

  tags = {
    Name = "simple web"
  }

  volume_tags = {
    Name = "simple web"
  } 
}

resource "aws_security_group" "sg" {
  name        = "allow_ssh_http"
  description = "Allow ssh http inbound traffic"
  vpc_id      = aws_vpc.customer-vpc.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "ICMP from VPC"
    from_port        = 8
    to_port          = 0
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh_http"
  }
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}