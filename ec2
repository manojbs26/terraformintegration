provider "aws" {
    region = "ap-south-1"
}

resource "aws_instance" "terraform-instance" {
    ami = "ami-0ad21ae1d0696ad58"
    instance_type = "t2.micro"
    key_name = "OPQ key"
    tags = {
      "Name" = "test"
    }
}
