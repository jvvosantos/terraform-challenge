resource "aws_security_group" "lb_sg" {
  name   = "elb_sg"
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]

  # Not ideal, but did this for the sake of simplicity
  subnets = [aws_subnet.public[0].id, aws_subnet.public[1].id]

  #enable_deletion_protection = true
}

resource "aws_lb_target_group" "server_tg" {
  name     = "server-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.default.id
}

resource "aws_lb_target_group_attachment" "server_tg_attatchment" {
  target_group_arn = aws_lb_target_group.server_tg.arn
  target_id        = aws_instance.nginx_server.id
  port             = 80
}

resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "443"
  protocol          = "HTTPS"

  # used statically for simplicity
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:680771576532:certificate/ebe045ef-7591-4b78-820e-f0c930a32833"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.server_tg.arn
  }
}

resource "aws_lb_listener" "app_lb_listener_http_to_https" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_route53_record" "terraform_record" {
  zone_id = var.aws_hosted_zone_id
  name    = "terraform.jvos.me"
  type    = "A"

  alias {
    name                   = aws_lb.app_lb.dns_name
    zone_id                = aws_lb.app_lb.zone_id
    evaluate_target_health = true
  }
}