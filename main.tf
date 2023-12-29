resource "aws_key_pair" "basil" {
  key_name   = "${var.project}-${var.env}"
  public_key = file("mykey.pub")
  tags = {
    Name    = "${var.project}-${var.env}-key"
    project = var.project
    env     = var.env
  }
}


resource "aws_security_group" "allow_ports" {
  name        = "${var.project}-${var.env}-ssh-http-&-https-access"
  description = "${var.project}-${var.env}-ssh-http-&-https-access"

  ingress {
    description      = "Secure Access"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  ingress {
    description      = "Insecure Access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
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
    Name        = "${var.project}-${var.env}-ssh-http-&-https-access"
    project     = var.project
    environment = var.env
  }
}


resource "aws_instance" "RacingClub" {
  ami                    = data.aws_ami.latest.id 
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.allow_ports.id]
  key_name               = aws_key_pair.basil.key_name
  tags = {
    Name        = "${var.project}-${var.env}-RacingClub"
    project     = var.project
    environment = var.env
  }
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_route53_record" "frontend-dev" {
  zone_id = var.hosted_zone_id
  name    = "${var.hostname}.${var.hosted_zone_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.RacingClub.public_ip]
}
