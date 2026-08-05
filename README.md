# CI/CD Todo App — GitHub Actions

Java Spring Boot Todo application delivered to AWS through a GitHub Actions CI/CD workflow. Terraform creates the AWS infrastructure, while GitHub Actions builds and verifies the application, checks code quality in SonarQube Cloud, publishes a Docker image to Amazon ECR, and deploys it to Amazon ECS Fargate.

This branch contains the GitHub Actions implementation of the project.

## Architecture

The project separates infrastructure provisioning from application delivery.

**Infrastructure:**

```text
Local workstation → Terraform → AWS infrastructure
```

**Application delivery:**

```text
GitHub → GitHub Actions → Maven and Checkstyle → SonarQube Cloud
       → Docker → Amazon ECR → Amazon ECS Fargate → Application Load Balancer
```

Terraform is run manually when the infrastructure needs to be created or changed. It is not executed on every application push. Once the AWS resources exist, each push to `github-actions` can build and deploy a new application version.

## Delivery flow

1. A push or pull request starts the workflow.
2. A GitHub-hosted runner checks out the repository and installs Java 21.
3. Maven builds the application, runs the tests, and creates the Checkstyle report.
4. SonarQube Cloud analyses the project and returns the Quality Gate result.
5. The JAR is uploaded as a workflow artifact.
6. For a deployment run, a second runner downloads the JAR and configures AWS access.
7. The runner builds a Docker image and pushes it to Amazon ECR using the workflow run number as the image tag.
8. GitHub Actions creates a new ECS task definition revision with the new image.
9. The ECS service is updated and the workflow waits until it becomes stable.

Pull requests run the validation job only. Deployment runs for pushes and manual workflow runs on the `github-actions` branch.

## Technology stack

|Area|Tools|
|-|-|
|Application|Java 21, Spring Boot, Maven|
|CI/CD|GitHub Actions|
|Code quality|Checkstyle, SonarQube Cloud Quality Gate|
|Infrastructure as Code|Terraform|
|Containers|Docker|
|AWS|ECR, ECS Fargate, ALB, IAM, CloudWatch Logs|
|Version control|Git, GitHub|

## Repository structure

|Path|Purpose|
|-|-|
|`.github/workflows/deploy.yml`|Build, quality checks, image publishing, and ECS deployment|
|`terraform/`|AWS infrastructure managed by Terraform|
|`aws/task-definition-template.json`|ECS task definition template rendered during deployment|
|`Dockerfile`|Runtime image for the Spring Boot application|
|`.dockerignore`|Limits the Docker build context to the required files|
|`pom.xml`|Maven dependencies and build configuration|
|`src/`|Application source code and tests|
|`data/`|Local SQLite data directory placeholder|
|`docs/`|Detailed project documentation|

## CI/CD implementations

|Branch|CI/CD platform|Infrastructure|
|-|-|-|
|`main`|Jenkins|Terraform and Ansible|
|`github-actions`|GitHub Actions|Terraform|
|`gitlab-ci`|GitLab CI|Terraform and Ansible|

The application and AWS deployment model are similar across the branches. The main difference is the CI/CD platform and the supporting automation required by it.

## Run locally

Prerequisites:

* Java 21
* Maven 3.9 or newer
* Git

Clone the repository and select this branch:

```bash
git clone https://github.com/yaromacarano/CICD-todoApp.git
cd CICD-todoApp
git checkout github-actions
```

Build and verify the application:

```bash
mvn clean verify
```

Start it locally:

```bash
mvn spring-boot:run
```

Open `http://localhost:8080`.

See [Local Run Guide](docs/02-local-run.md) for more detail.

## Run with Docker

Build the JAR and Docker image:

```bash
mvn clean package -DskipTests
docker build -t todo-app:github-actions .
```

Start the container:

```bash
docker run --rm -p 8080:8080 todo-app:github-actions
```

Open `http://localhost:8080`. See [Docker Guide](docs/03-docker.md) for more detail.

## Create the AWS infrastructure

Terraform uses the AWS default VPC and creates the ECR repository, ECS Fargate service, Application Load Balancer, security groups, CloudWatch log group, and ECS task execution role.

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

Terraform is run separately from the application workflow. After the first `apply`, configure the required GitHub Secrets and Variables, then start the workflow manually from the Actions page. Later application changes deploy automatically on push.

See [Terraform Infrastructure](docs/07-terraform.md) for the complete setup and first-deployment sequence.

## GitHub Actions configuration

Open:

```text
Repository → Settings → Secrets and variables → Actions
```

Required secrets:

|Secret|Purpose|
|-|-|
|`SONAR\_TOKEN`|Authenticates the Maven scanner with SonarQube Cloud|
|`AWS\_ACCESS\_KEY\_ID`|Authenticates the deployment job with AWS|
|`AWS\_SECRET\_ACCESS\_KEY`|Authenticates the deployment job with AWS|

Required variables:

|Variable|Current project value|
|-|-|
|`SONAR\_ORGANIZATION`|SonarQube Cloud organization key|
|`SONAR\_PROJECT\_KEY`|SonarQube Cloud project key|
|`AWS\_REGION`|`us-east-1`|
|`ECR\_REPOSITORY`|`todo-app`|
|`CONTAINER\_NAME`|`todo`|
|`SERVICE`|`todo-ecs-service`|
|`CLUSTER`|`newcluster`|

`SONAR\_HOST\_URL` is not required because analysis uses SonarQube Cloud rather than a self-hosted SonarQube server.

## Workflow triggers

|Event|Validation|Deployment|
|-|-|-|
|Push to `github-actions`|Yes|Yes|
|Pull request to `github-actions`|Yes|No|
|Manual run on `github-actions`|Yes|Yes|

Terraform does not send an event to GitHub after `terraform apply`. For the first deployment, create the infrastructure and then start `Todo CI/CD WF` manually. Once the environment exists, normal pushes are enough.

## Documentation

* [Project Overview](docs/01-project-overview.md)
* [Local Run Guide](docs/02-local-run.md)
* [Docker Guide](docs/03-docker.md)
* [GitHub Actions Workflow](docs/04-github-actions-workflow.md)
* [AWS ECR and ECS](docs/05-aws-ecr-ecs.md)
* [Troubleshooting](docs/06-troubleshooting.md)
* [Terraform Infrastructure](docs/07-terraform.md)

## Security

Secrets and Terraform state are not committed to the repository. The `.gitignore` excludes `terraform.tfvars`, state files, plan files, credentials, and private keys.

Screenshots should be checked before committing so they do not expose tokens, credentials, account details, or other sensitive values.

