
resource "aws_service_discovery_service" "miniapi" {
  name = "miniapi"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.demo.id

    dns_records {
      ttl  = 10
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

  enable_execute_command = true

  network_configuration {
    subnets          = var.subnets
    security_groups  = [aws_security_group.demo.id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.miniapi.arn
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}
