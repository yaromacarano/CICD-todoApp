resource "aws_cloudwatch_log_group" "todo" {
  name              = "/ecs/${var.project_name}-task"
  retention_in_days = 7

  tags = {
    Name = "/ecs/${var.project_name}-task"
  }
}

resource "aws_ecs_cluster" "todo" {
  name = "${var.project_name}-cluster"

  tags = {
    Name = "${var.project_name}-cluster"
  }
}

resource "aws_ecs_task_definition" "todo" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "3072"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = "todo"
      image     = "${aws_ecr_repository.todo.repository_url}:latest"
      cpu       = 0
      essential = true

      portMappings = [
        {
          name          = "todo-8080-tcp"
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]

      environment = []

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.todo.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution]

  tags = {
    Name = "${var.project_name}-task"
  }
}

resource "aws_ecs_service" "todo" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.todo.id
  task_definition = aws_ecs_task_definition.todo.arn
  desired_count   = var.ecs_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = local.default_subnet_ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.todo.arn
    container_name   = "todo"
    container_port   = 8080
  }

  lifecycle {
    ignore_changes = [task_definition]
  }

  depends_on = [aws_lb_listener.http]

  tags = {
    Name = "${var.project_name}-service"
  }
}
