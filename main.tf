provider "aws" {
  access_key = ""
  secret_key = ""
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}
resource "aws_internet_gateway" "main-ig" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "main-ig"
    }
}


# Setting up the route table
resource "aws_route_table" "pub-rt" {
    vpc_id = aws_vpc.main.id
    route {
        # pointing to the internet
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main-ig.id
    }
    route {
        ipv6_cidr_block = "::/0"
        gateway_id = aws_internet_gateway.main-ig.id
    }
    tags = {
        Name = "pub-rt"
    }
}

# Create a subnet
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "main-subnet"
  }
}
# Associating the subnet with the route table
resource "aws_route_table_association" "pub-sub-rt-assoc" {
    subnet_id = aws_subnet.main.id
    route_table_id = aws_route_table.pub-rt.id
}

# Create a security group
resource "aws_security_group" "instance_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "instance-sg"
  }
}


resource "aws_instance" "jenkins-master" {
  ami           = "ami-04a81a99f5ec58529"
  instance_type = "t2.small"
  key_name = "my-keypair"
  associate_public_ip_address = true
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  tags = {
    Name = "jenkins-master"
  }
}

resource "aws_instance" "kubernetes-master" {
 
  key_name = "my-keypair"
  ami           = "ami-04a81a99f5ec58529"
  instance_type = "t2.medium"
  associate_public_ip_address = true
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  tags = {
    Name = "kubernetes-master"
  }
}

resource "aws_instance" "worker-node" {

  key_name = "my-keypair"
  ami           = "ami-04a81a99f5ec58529"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  tags = {
    Name = "worker-node"
  }
}

