resource "aws_lb" "lb" {
  name               = local.cluster_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = var.subnets
}


locals {
  lb_sg_name = "lb"
}

resource "aws_security_group" "lb" {
  name        = local.lb_sg_name
  description = local.lb_sg_name
  vpc_id      = var.vpc_id

  ingress {
    description = "all from internet"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.lb_sg_name
  }
}

resource "aws_lb_listener" "kubecache" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "8001"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kubecache.arn
  }
}

resource "aws_lb_listener" "miniapi" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "8002"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.miniapi.arn
  }
}

resource "aws_lb_target_group" "kubecache" {
  name        = "kubecache"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  // https://docs.aws.amazon.com/AmazonECS/latest/developerguide/load-balancer-connection-draining.html
  deregistration_delay = 5

  // https://docs.aws.amazon.com/AmazonECS/latest/developerguide/load-balancer-healthcheck.html
  health_check {
    enabled           = true
    interval          = 5
    timeout           = 4
    healthy_threshold = 2
    path              = "/health"
    protocol          = "HTTP"
    port              = "traffic-port"
  }
}

resource "aws_lb_target_group" "miniapi" {
  name        = "miniapi"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  // https://docs.aws.amazon.com/AmazonECS/latest/developerguide/load-balancer-connection-draining.html
  deregistration_delay = 5

  // https://docs.aws.amazon.com/AmazonECS/latest/developerguide/load-balancer-healthcheck.html
  health_check {
    enabled           = true
    interval          = 5
    timeout           = 4
    healthy_threshold = 2
    path              = "/health"
    protocol          = "HTTP"
    port              = "traffic-port"
  }
}
