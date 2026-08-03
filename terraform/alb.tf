resource "aws_lb" "todo" {
  name               = "todo-ELB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = local.alb_subnet_ids

  lifecycle {
    precondition {
      condition     = length(local.default_subnet_ids) >= 2
      error_message = "The default VPC must have subnets in at least two Availability Zones."
    }
  }

  tags = {
    Name = "todo-ELB"
  }
}

resource "aws_lb_target_group" "todo" {
  name        = "todo-target-group"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.default.id

  health_check {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "todo-target-group"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.todo.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.todo.arn
  }
}
