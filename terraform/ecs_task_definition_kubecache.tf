resource "aws_ecs_task_definition" "kubecache" {
  family = "kubecache"

  // https://docs.aws.amazon.com/AmazonECS/latest/developerguide/create-task-definition.html

  container_definitions = jsonencode([
    {
      name      = "kubecache"
      image     = "docker.io/udhos/kubecache:latest"
      essential = true
      portMappings = [
        {
          "name" : "kubecache",
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
          awslogs-group         = "/ecs/demo/kubecache"
          awslogs-region        = "${var.region}"
          awslogs-stream-prefix = "demo-kubecache"
        }
      }

      // https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_HealthCheck.html
      healthCheck = {
        command = [
          "CMD-SHELL",
          "curl -f http://localhost:8888/health || exit 1"
        ],
        interval    = 10 # default: 30
        retries     = 3  # default: 3
        startPeriod = 0  # default: 0
        timeout     = 5  # default: 5
      },

      environment = [
        {
          name  = "TRACE"
          value = "false"
        },
        {
          name  = "BACKEND_URL"
          value = "http://miniapi.demo:8080"
        },
        {
          name  = "COMPUTE"
          value = "ecs"
        },
        {
          name  = "GROUPCACHE_VERSION"
          value = "${var.groupcache_version}"
        }
      ]

    }
  ])

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = 256
  memory = 512

  // The task execution role grants the Amazon ECS container and Fargate agents permission to make AWS API calls on your behalf. 
  execution_role_arn = aws_iam_role.kubecache_execution_role.arn

  // This role allows your application code (on the container) to use other AWS services. The task role is required when your application accesses other AWS services, such as Amazon S3.
  task_role_arn = aws_iam_role.kubecache_task_role.arn
}

# ----------------------------

data "aws_iam_policy_document" "kubecache_execution_role_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "kubecache_execution_role" {
  name               = "kubecache_execution_role"
  assume_role_policy = data.aws_iam_policy_document.kubecache_execution_role_trust.json
}

resource "aws_iam_role_policy_attachment" "kubecache_execution_role" {
  role       = aws_iam_role.kubecache_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "kubecache_execution_role" {
  name = "kubecache_execution_role"
  role = aws_iam_role.kubecache_execution_role.id

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

data "aws_iam_policy_document" "kubecache_task_role_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "kubecache_task_role" {
  name               = "kubecache_task_role"
  assume_role_policy = data.aws_iam_policy_document.kubecache_task_role_trust.json
}

resource "aws_iam_role_policy" "kubecache_task_role" {
  name = "kubecache_task_role"
  role = aws_iam_role.kubecache_task_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "ecsExec",
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Sid = "ecsTaskDiscovery",
        Action = [
          "ecs:ListTasks",
          "ecs:DescribeTasks"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
