######################
# IAM Role for ECS Task Execution
######################
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the standard AWS managed policy for ECS execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

######################
# ECS Cluster
######################
resource "aws_ecs_cluster" "pet_store" {
  name = "pet-store-cluster"

  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }

  service_connect_defaults {
    namespace = "arn:aws:servicediscovery:us-east-1:652821469274:namespace/ns-rxipfq3jzurkxcoa"
  }

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

######################
# ECS Task Definition
######################
resource "aws_ecs_task_definition" "pet_store_ui" {
  family                   = "pet-store-ui-task"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name         = "pet-store-ui"
      image        = "652821469274.dkr.ecr.us-east-1.amazonaws.com/pet-store-ui:latest"
      essential    = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-create-group  = "true"
          awslogs-group         = "/ecs/pet-store-ui-task"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

######################
# ECS Service
######################
resource "aws_ecs_service" "pet_store_service" {
  name                               = "pet-store-ui-service"
  cluster                            = aws_ecs_cluster.pet_store.id
  task_definition                    = aws_ecs_task_definition.pet_store_ui.arn
  desired_count                      = 3
  launch_type                        = "FARGATE"
  platform_version                   = "LATEST"
  enable_ecs_managed_tags            = true
  propagate_tags                     = "NONE"
  scheduling_strategy                = "REPLICA"
  health_check_grace_period_seconds  = 0
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  deployment_controller {
    type = "ECS"
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    assign_public_ip = true
    security_groups  = ["sg-0cc59a12bc8e5ee22"]
    subnets          = [
      "subnet-0224e9f71d9c9c6d1",
      "subnet-04b3fe07d0f9c0150",
      "subnet-06f3350e62a2c834c",
      "subnet-07fd2902ba90f2d0e",
      "subnet-0b2e64eec89ec873b",
      "subnet-0b75062a27489c199"
    ]
  }
}
