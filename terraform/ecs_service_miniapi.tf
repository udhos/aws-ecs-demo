
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
  desired_count   = var.min_capacity

  enable_execute_command = var.enable_execute_command

  network_configuration {
    subnets          = var.subnets
    security_groups  = [aws_security_group.demo.id]
    assign_public_ip = var.assign_public_ip
  }

  service_registries {
    registry_arn = aws_service_discovery_service.miniapi.arn
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.miniapi.arn
    container_name   = "miniapi"
    container_port   = 8080
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_appautoscaling_target" "miniapi" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${aws_ecs_cluster.demo.name}/${aws_ecs_service.miniapi.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "miniapi" {
  name               = "miniapi"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.miniapi.resource_id
  scalable_dimension = aws_appautoscaling_target.miniapi.scalable_dimension
  service_namespace  = aws_appautoscaling_target.miniapi.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 50
    scale_in_cooldown  = 60
    scale_out_cooldown = 30
  }
}
