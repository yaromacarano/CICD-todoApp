resource "aws_ecr_repository" "todo" {
  name                 = "todo-app"
  image_tag_mutability = "MUTABLE"
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = {
    Name = "todo-app"
  }
}
