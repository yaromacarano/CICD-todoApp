# Troubleshooting

This guide starts with the simplest checks: the failed GitHub Actions step, the related GitHub setting, and the matching page in the AWS Console.

## Local build fails

Check the installed versions:

```bash
java -version
mvn -version
```

The project uses Java 21. Then run:

```bash
mvn clean verify
```

Read the first Maven error in the output. Later messages are often consequences of the first failure.

## The JAR is missing

The Dockerfile expects:

```text
target/todolist-app-1.0.0.jar
```

Create it with:

```bash
mvn clean package
```

## Docker build fails

Confirm that Docker is running and the JAR exists:

```bash
docker version
ls -l target/todolist-app-1.0.0.jar
```

Then retry:

```bash
docker build -t todo-app:github-actions .
```

## Container runs but the page does not open

Check the container and its logs:

```bash
docker ps -a
docker logs <container_id>
```

The application must be published with port mapping `8080:8080`:

```bash
docker run --rm -p 8080:8080 todo-app:github-actions
```

## Workflow does not start

Open `.github/workflows/deploy.yml` and confirm that it exists in the `github-actions` branch.

The current triggers are:

- push to `github-actions`;
- pull request to `github-actions`;
- manual start through `workflow_dispatch`.

If the **Run workflow** button is missing, select the workflow from the Actions page and confirm that the workflow file also exists on the repository default branch. Then select `github-actions` in the branch menu before starting it.

## SonarQube Cloud analysis fails

Open the failed `Build, Test, Checkstyle and SonarQube Cloud Analysis` step.

Check these repository settings:

| Type | Name |
| --- | --- |
| Secret | `SONAR_TOKEN` |
| Variable | `SONAR_ORGANIZATION` |
| Variable | `SONAR_PROJECT_KEY` |

Then compare the organization and project keys with the SonarQube Cloud project. They are keys, not display names.

`SONAR_HOST_URL` is not used in this branch. There is no self-hosted SonarQube server to check.

If the log reaches `Waiting for the analysis report to be processed` and then fails, open the project in SonarQube Cloud and check:

- that the analysed branch exists;
- that the token owner can analyse the project;
- that the Quality Gate result is available;
- that CI-based analysis is enabled and Automatic Analysis is disabled.

If needed, create a new SonarQube Cloud token, replace only the `SONAR_TOKEN` secret in GitHub, and run the workflow again.

## Quality Gate fails

Open the project in SonarQube Cloud and read the failed condition. The workflow is working correctly when it stops deployment after a failed Quality Gate.

Typical reasons are:

- a new issue was detected;
- required coverage was not reached;
- a security hotspot needs review;
- the analysis report is incomplete.

Fix the reported condition or adjust the project Quality Gate only when the rule does not match the intended policy.

## Pull request analysis cannot read `SONAR_TOKEN`

GitHub does not pass repository secrets to workflows from untrusted forks. A fork-based pull request can therefore fail at the SonarQube Cloud step even if the secret is correct.

For this project, run the branch from the same repository or review the pull request without exposing the secret to external code.

## Artifact upload or download fails

The first job uploads:

```text
name: todolist-app-1.0.0
path: target/*.jar
```

The deployment job must download the same artifact name into `target/`. If upload fails, check the Maven step first. If download fails, compare the artifact names in both steps.

## AWS credentials step fails

Check the failed `Configure AWS Credentials` step and then verify:

| Type | Name |
| --- | --- |
| Secret | `AWS_ACCESS_KEY_ID` |
| Secret | `AWS_SECRET_ACCESS_KEY` |
| Variable | `AWS_REGION` |

The current region is `us-east-1`. Confirm that the AWS IAM user or role is active and that the access keys have not been removed or replaced.

## ECR push fails

Check the `Login to Amazon ECR` or `Build, tag and push image to ECR` step.

Then open the AWS Console:

1. Go to **Amazon ECR**.
2. Confirm that repository `todo-app` exists in `us-east-1`.
3. Confirm that GitHub Variable `ECR_REPOSITORY` is exactly `todo-app`.
4. Check that the GitHub Actions AWS identity has permission to push images.

If Terraform was not applied, create the infrastructure before rerunning the workflow.

## Task definition rendering fails

Check that:

- `aws/task-definition-template.json` exists;
- the file contains valid JSON;
- GitHub Variable `CONTAINER_NAME` is `todo`;
- the template contains a container named `todo`;
- `executionRoleArn` refers to `ecsTaskExecutionRole`.

## ECS deployment fails

Confirm the GitHub Variables:

| Variable | Expected value |
| --- | --- |
| `CLUSTER` | `newcluster` |
| `SERVICE` | `todo-ecs-service` |
| `CONTAINER_NAME` | `todo` |

Then use the AWS Console:

1. Open **Amazon ECS**.
2. Select cluster `newcluster` and service `todo-ecs-service`.
3. Read the latest message in **Events**.
4. Open the stopped task if one exists.
5. Check its stop reason and CloudWatch log link.

The event or stop reason usually identifies the problem more clearly than the GitHub Actions message.

## ECS task cannot pull the image

This can happen during the first Terraform run because the initial task definition uses the `latest` image before ECR contains an image.

Run the GitHub Actions workflow manually on `github-actions`. The workflow pushes an image with the run number, registers a new task definition revision, and updates the service.

If the problem continues, confirm that:

- the new image appears in ECR;
- the latest ECS task definition points to that exact image;
- `ecsTaskExecutionRole` exists;
- the role has `AmazonECSTaskExecutionRolePolicy` attached.

## Target is unhealthy or application does not open

Check in this order:

1. ECS service has one running task.
2. The target group shows the task as healthy.
3. The target group uses port `8080` and health path `/`.
4. The ECS security group allows port `8080` from the ALB security group.
5. The ALB listener uses port `80`.
6. CloudWatch Logs do not show an application startup error.

Use the `application_url` shown by Terraform rather than the ECS task IP.

## Terraform reports that a resource already exists

Terraform uses fixed names such as `todo-app`, `newcluster`, and `ecsTaskExecutionRole`. The error usually means an older resource with the same name still exists in the AWS account.

Open the matching AWS service in the Console and decide whether the old resource should be removed or imported into the current Terraform state. Do not delete a resource until you have confirmed that it is not used by another project.

## `terraform destroy` cannot delete ECR

The ECR repository uses `force_delete = false`, so Terraform will not delete it while images remain.

1. Open **Amazon ECR** in the AWS Console.
2. Open `todo-app` and delete its images.
3. Run `terraform destroy` again.

## Terraform wants to recreate existing resources

The project currently uses local Terraform state. Confirm that you are working in the same `terraform/` directory and still have the original `terraform.tfstate` file.

Do not create an empty state file and do not commit state to Git. If the state was lost, stop before applying and recover the original state or import the existing resources.

## Screenshot safety

Before committing screenshots, hide:

- access keys and secret values;
- tokens and passwords;
- private account or infrastructure information;
- personal information.
