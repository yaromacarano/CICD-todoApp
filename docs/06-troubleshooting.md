# Troubleshooting

## Terraform authentication

```bash
aws sts get-caller-identity
```

Terraform uses local AWS credentials. The limited GitLab CI keys are created later by Terraform.

## Terraform subnet error

The ALB requires default subnets in at least two Availability Zones. Select a region with a default VPC and at least two default subnets.

## Ansible connection

Check the Runner private IP, SSH key path, key mode and security groups.

```bash
chmod 400 ~/.ssh/todo-app-key.pem
ansible all -m ping
```

## Missing Runner token

```bash
read -s -p "GitLab Runner token: " GITLAB_RUNNER_TOKEN
echo
export GITLAB_RUNNER_TOKEN
ansible-playbook playbooks/site.yml
```

The token must start with `glrt-`.

## Runner remains offline

```bash
sudo systemctl status gitlab-runner
sudo gitlab-runner verify --config /etc/gitlab-runner/config.toml
sudo journalctl -u gitlab-runner -n 50 --no-pager
```

If the first playbook run stopped before registration, check the configuration:

```bash
sudo grep '^\[\[runners\]\]' /etc/gitlab-runner/config.toml
```

When no section is found, export the token again and rerun the playbook. The playbook retries registration even if an empty `config.toml` exists.

Also verify the Runner tags `aws`, `docker`, `ec2`, project assignment and protected status in GitLab.

## Docker-in-Docker connection

`/etc/gitlab-runner/config.toml` must contain:

```toml
privileged = true
volumes = ["/certs/client", "/cache"]
```

Restart the Runner after a configuration change:

```bash
sudo systemctl restart gitlab-runner
```

## SonarQube Cloud failure

Check:

- `SONAR_TOKEN`, `SONAR_ORGANIZATION` and `SONAR_PROJECT_KEY`;
- access to variables from the current branch;
- compiled classes, JUnit reports and Checkstyle report in job artifacts;
- repository binding in SonarQube Cloud.

## InvalidClientTokenId or SignatureDoesNotMatch

Check that:

- `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` match Terraform outputs;
- values contain no quotes or spaces;
- the variables are available to `main`.

## AccessDenied

The job log must show the dedicated GitLab CI user:

```bash
aws sts get-caller-identity
```

Reapply Terraform if the user policy is missing:

```bash
cd terraform
terraform apply
```

`ECS_TASK_EXECUTION_ROLE_ARN` must contain the ECS execution role, not the GitLab IAM user ARN.

## AWS CLI failure in push-image-job

Confirm that `apk update`, `apk upgrade --no-cache` and `apk add --no-cache aws-cli` completed successfully.

## ECR push failure

Check `ECR_REPOSITORY_URL`, `AWS_DEFAULT_REGION`, AWS identity and Docker-in-Docker status.

## ECS deployment failure

Compare ECS variables with `terraform output` and confirm that the current image tag exists in ECR.

If the service does not stabilize, check ECS service events and CloudWatch logs. Typical causes are an invalid image URI, wrong execution role, failed application startup or failed health checks on port `8080`.
