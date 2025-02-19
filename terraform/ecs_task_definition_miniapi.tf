resource "aws_ecs_task_definition" "miniapi" {
  family = "miniapi"

  // https://docs.aws.amazon.com/AmazonECS/latest/developerguide/create-task-definition.html

  container_definitions = jsonencode([
    {
      name      = "miniapi"
      image     = "docker.io/udhos/miniapi:latest"
      essential = true
      portMappings = [
        {
          "name" : "miniapi",
          "containerPort" : 8080,
          "hostPort" : 8080,
          "protocol" : "tcp",
          "appProtocol" : "http"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-create-group  = "true"
          awslogs-group         = "/ecs/demo/miniapi"
          awslogs-region        = "${var.region}"
          awslogs-stream-prefix = "demo-miniapi"
        }
      }

      // https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_HealthCheck.html
      healthCheck = {
        command = [
          "CMD-SHELL",
          "curl -f http://localhost:8080/health || exit 1"
        ],
        interval    = 10 # default: 30
        retries     = 3  # default: 3
        startPeriod = 0  # default: 0
        timeout     = 5  # default: 5
      },

      environment = [
        {
          name  = "ROUTE"
          value = "/v1/hello;/v1/world;/card/{cardId}"
        }
      ]

    }
  ])

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = 256
  memory = 512

  // The task execution role grants the Amazon ECS container and Fargate agents permission to make AWS API calls on your behalf. 
  execution_role_arn = aws_iam_role.miniapi_execution_role.arn

  // This role allows your application code (on the container) to use other AWS services. The task role is required when your application accesses other AWS services, such as Amazon S3.
  task_role_arn = aws_iam_role.miniapi_task_role.arn
}

# ----------------------------

data "aws_iam_policy_document" "miniapi_execution_role_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "miniapi_execution_role" {
  name               = "miniapi_execution_role"
  assume_role_policy = data.aws_iam_policy_document.miniapi_execution_role_trust.json
}

resource "aws_iam_role_policy_attachment" "miniapi_execution_role" {
  role       = aws_iam_role.miniapi_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "miniapi_execution_role" {
  name = "miniapi_execution_role"
  role = aws_iam_role.miniapi_execution_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# ----------------------------

data "aws_iam_policy_document" "miniapi_task_role_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "miniapi_task_role" {
  name               = "miniapi_task_role"
  assume_role_policy = data.aws_iam_policy_document.miniapi_task_role_trust.json
}

resource "aws_iam_role_policy" "miniapi_task_role" {
  name = "miniapi_task_role"
  role = aws_iam_role.miniapi_task_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
