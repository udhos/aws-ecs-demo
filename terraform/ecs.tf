
locals {
  cluster_name = "demo"
}

resource "aws_ecs_cluster" "demo" {
  name = local.cluster_name

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "demo" {
  cluster_name = aws_ecs_cluster.demo.name

  capacity_providers = ["FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE_SPOT"
  }
}

resource "aws_service_discovery_private_dns_namespace" "demo" {
  name        = local.cluster_name
  description = local.cluster_name
  vpc         = var.vpc_id
}

resource "aws_security_group" "demo" {
  name        = local.cluster_name
  description = local.cluster_name
  vpc_id      = var.vpc_id

  ingress {
    description = "all from vpc cidr"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = var.cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.cluster_name
  }
}
