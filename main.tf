provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "terraform_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    name = "terraform_vpc"
  }
}

resource "aws_subnet" "terraform_subnet" {
  vpc_id                  = aws_vpc.terraform_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "test-subnet"
  }


}

resource "aws_internet_gateway" "terraform_ig" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    "Name" = "test-ig"
  }

}

resource "aws_route_table" "terra_rt" {
  vpc_id = aws_vpc.terraform_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform_ig.id
  }

  tags = {
    "Name" = "test-rt"
  }


}

resource "aws_route_table_association" "terra_rt_association" {
  subnet_id      = aws_subnet.terraform_subnet.id
  route_table_id = aws_route_table.terra_rt.id

  

}

resource "aws_security_group" "terra_sg" {
  description = "allow tcs inbond traffic and all out bound traffic"
  vpc_id      = aws_vpc.terraform_vpc.id

  ingress {
    description = "allow ssh port"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.terraform_vpc.cidr_block]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
  }


}

resource "aws_instance" "terraform-instance" {
  subnet_id       = aws_subnet.terraform_subnet.id
  ami             = "ami-0ad21ae1d0696ad58"
  instance_type   = "t2.micro"
  key_name        = "terra"
  security_groups = [aws_security_group.terra_sg.id]
  tags = {
    "Name" = "test"
  }
}
resource "aws_s3_bucket" "remote-state" {
    bucket = "terraform-state-file-26072024"
    force_destroy = true 
}

resource "aws_s3_bucket_versioning" "s3-versioning" {
    bucket = aws_s3_bucket.remote-state.id
    versioning_configuration {
      status = "Enabled"
    }
}

resource "aws_dynamodb_table" "remote-statelock" {
    name = "dynamodb-statelock"
    billing_mode = "PROVISIONED"
    read_capacity = 20
    write_capacity = 20
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}
