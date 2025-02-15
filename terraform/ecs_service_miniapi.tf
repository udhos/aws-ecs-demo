
resource "aws_service_discovery_service" "miniapi" {
  name = "miniapi"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.demo.id

    dns_records {
      ttl  = var.dns_ttl_seconds
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }
}

resource "aws_ecs_service" "miniapi" {
  name            = "miniapi"
  cluster         = aws_ecs_cluster.demo.id
  task_definition = aws_ecs_task_definition.miniapi.arn
  desired_count   = 1

  enable_execute_command = var.enable_execute_command

  network_configuration {
    subnets          = var.subnets
    security_groups  = [aws_security_group.demo.id]
    assign_public_ip = var.assign_public_ip
  }

  service_registries {
    registry_arn = aws_service_discovery_service.miniapi.arn
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}
