resource "aws_iam_user" "gitlab_ci" {
  name = "${var.project_name}-gitlab-ci"

  tags = {
    Name = "${var.project_name}-gitlab-ci"
  }
}

data "aws_iam_policy_document" "gitlab_ci" {
  statement {
    sid    = "GetEcrLoginToken"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "PushImageToProjectRepository"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]

    resources = [aws_ecr_repository.todo.arn]
  }

  statement {
    sid    = "DeployToEcs"
    effect = "Allow"

    actions = [
      "ecs:DescribeServices",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "PassOnlyTheEcsExecutionRole"
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = [aws_iam_role.ecs_task_execution.arn]
  }
}

resource "aws_iam_user_policy" "gitlab_ci" {
  name   = "${var.project_name}-gitlab-deploy"
  user   = aws_iam_user.gitlab_ci.name
  policy = data.aws_iam_policy_document.gitlab_ci.json
}

resource "aws_iam_access_key" "gitlab_ci" {
  user = aws_iam_user.gitlab_ci.name
}
