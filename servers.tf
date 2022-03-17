resource "aws_security_group" "http_server_sg" {
  name   = "http_server_sg"
  vpc_id = aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx_server" {
  ami                         = "ami-07eaf2ea4b73a54f6"
  key_name                    = "ec2-key"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.http_server_sg.id]
  subnet_id                   = aws_subnet.private[0].id
  associate_public_ip_address = false
  user_data                   = file("install_nginx.sh")
}