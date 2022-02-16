provider "aws" {
    region = var.region
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable az {}
variable region {}
variable my_ip {}
variable instance_type {}
variable public_key_location {}
variable instance_count {}
variable ami {}


resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "public-subnet-1" {
  vpc_id     = aws_vpc.myapp-vpc.id
  cidr_block = var.subnet_cidr_block
  map_public_ip_on_launch = true
  availability_zone = var.az
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_default_security_group" "default-sg" {
  vpc_id      = aws_vpc.myapp-vpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip]
  }

  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "default-sg"
  }
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id

  tags = {
    Name = "myigw"
  }
}

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }

  tags = {
    Name = "my-main-rtb"
  }
}



output "ec2_public_ip" {
  value       = aws_instance.myapp-server.*.public_ip
}


resource "aws_instance" "myapp-server" {
  ami           = var.ami
  instance_type = var.instance_type
  count = "${var.instance_count}"
  subnet_id = aws_subnet.public-subnet-1.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.az
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  tags = {
    Name = "Server-${count.index+1}"
  }

  }


resource "aws_key_pair" "ssh-key" {
  key_name   = "server-key"
  public_key = file(var.public_key_location)
}