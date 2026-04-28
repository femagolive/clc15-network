## Criação da VPC
resource "aws_vpc" "terraform_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "clc15-tf-vpc"
  }
}

## Subnets AZ 1a
resource "aws_subnet" "public_subnet_1a" {
  vpc_id     = aws_vpc.terraform_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public-tf-subnet-1a"
  }
}
resource "aws_subnet" "private_subnet_1a" {
  vpc_id     = aws_vpc.terraform_vpc.id
  cidr_block = "10.0.100.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-tf-subnet-1a"
  }
}

## Subnets AZ 1b
resource "aws_subnet" "public_subnet_1b" {
  vpc_id     = aws_vpc.terraform_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "public-tf-subnet-1b"
  }
}
resource "aws_subnet" "private_subnet_1b" {
  vpc_id     = aws_vpc.terraform_vpc.id
  cidr_block = "10.0.200.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-tf-subnet-1b"
  }
}

## Internet Gateway
resource "aws_internet_gateway" "tf_gw" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "tf-vpc-tf_igw"
  }
}

## Public Route Table
resource "aws_route_table" "tf-public-rt" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_gw.id
  }

  tags = {
    Name = "tf-public-rt"
  }
}

## Attach RT as publics subnets
resource "aws_route_table_association" "public_1a_association" {
  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.tf-public-rt.id
}

resource "aws_route_table_association" "public_1b_association" {
  subnet_id      = aws_subnet.public_subnet_1b.id
  route_table_id = aws_route_table.tf-public-rt.id
}

## Elastic IP
resource "aws_eip" "tf_ip_nat_1a" {
  domain   = "vpc"
}

resource "aws_eip" "tf_ip_nat_1b" {
  domain   = "vpc"
}

## Nat Gateway
resource "aws_nat_gateway" "tf_nat_1a" {
  allocation_id = aws_eip.tf_ip_nat_1a.id
  subnet_id     = aws_subnet.public_subnet_1a.id

  tags = {
    Name = "tf_nat_1a"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.tf_gw]
}

resource "aws_nat_gateway" "tf_nat_1b" {
  allocation_id = aws_eip.tf_ip_nat_1b.id
  subnet_id     = aws_subnet.public_subnet_1b.id

  tags = {
    Name = "tf_nat_1b"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.tf_gw]
}

## Private Route Table
resource "aws_route_table" "tf_private_rt_1a" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.tf_nat_1a.id
  }

  tags = {
    Name = "tf-private-rt-1a"
  }
}

resource "aws_route_table" "tf_private_rt_1b" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.tf_nat_1b.id
  }

  tags = {
    Name = "tf-private-rt-1b"
  }
}

## Attach  RT as privates subnets
resource "aws_route_table_association" "private_1a_association" {
  subnet_id      = aws_subnet.private_subnet_1a.id
  route_table_id = aws_route_table.tf_private_rt_1a.id
}

resource "aws_route_table_association" "private_1b_association" {
  subnet_id      = aws_subnet.private_subnet_1b.id
  route_table_id = aws_route_table.tf_private_rt_1b.id
}