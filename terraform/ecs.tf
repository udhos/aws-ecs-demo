
resource "aws_ecs_cluster" "demo" {
  name = "demo"

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
