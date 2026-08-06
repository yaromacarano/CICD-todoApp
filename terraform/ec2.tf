resource "aws_instance" "gitlab_runner" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.gitlab_runner_instance_type
  key_name                    = var.key_name
  subnet_id                   = local.ec2_subnet_id
  vpc_security_group_ids      = [aws_security_group.gitlab_runner.id]
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
    encrypted   = true
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name = "${var.project_name}-runner"
    Role = "GitLabRunner"
  }
}

resource "aws_instance" "ansible_controller" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.ansible_controller_instance_type
  key_name                    = var.key_name
  subnet_id                   = local.ec2_subnet_id
  vpc_security_group_ids      = [aws_security_group.ansible_controller.id]
  associate_public_ip_address = true
  user_data                   = templatefile("${path.module}/templates/ansible-controller-user-data.sh.tftpl", {})
  user_data_replace_on_change = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 12
    encrypted   = true
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name = "${var.project_name}-ansible-controller"
    Role = "AnsibleController"
  }
}
