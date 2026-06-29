data "aws_caller_identity" "current" {}

output "aws_account" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_user" {
  value = data.aws_caller_identity.current.arn
}

//create VPC
resource "aws_vpc" "project_vpc" {

  cidr_block = "10.20.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "project1-vpc"
  }

}

//create subnet
resource "aws_subnet" "project_subnet" {

  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "project1-subnet"
  }

}

//create internetgateway
resource "aws_internet_gateway" "project_igw" {

  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name = "project1-igw"
  }

}

//create route table
resource "aws_route_table" "project_rt" {

  vpc_id = aws_vpc.project_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project_igw.id
  }

  tags = {
    Name = "project1-route-table"
  }

}

//create route table association
resource "aws_route_table_association" "project_rta" {

  subnet_id      = aws_subnet.project_subnet.id
  route_table_id = aws_route_table.project_rt.id

}

//create security group
resource "aws_security_group" "project_sg" {
  name        = "project1-sg"
  description = "Project 1 Security Group"
  vpc_id      = aws_vpc.project_vpc.id

  tags = {
    Name = "project1-sg"
  }
}

//create EC2 instance
resource "aws_instance" "project_ec2" {
  ami                    = "ami-02d74237498939967"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.project_subnet.id
  vpc_security_group_ids = [aws_security_group.project_sg.id]

  associate_public_ip_address = true

  tags = {
    Name = "project1-ec2"
  }
}
