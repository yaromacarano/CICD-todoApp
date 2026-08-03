# CI/CD Todo App — DevOps Portfolio Project

Java Spring Boot Todo application with a Jenkins CI/CD pipeline, Docker image build, SonarQube quality checks, AWS ECR image publishing, AWS ECS task definition revision deployment, and infrastructure automation with Terraform and Ansible.

The application code is used as a base for demonstrating a practical DevOps workflow around build automation, containerization, quality control, and cloud deployment.

## Architecture

Terraform creates the AWS infrastructure. Ansible configures the EC2 servers. The application delivery flow remains:

GitHub Repository → Jenkins Controller → Jenkins Agent → AWS ECR → AWS ECS Service

The pipeline performs these steps:

1. Fetch source code from GitHub.
2. Run Maven verification.
3. Run Checkstyle analysis.
4. Send code analysis to SonarQube.
5. Validate the SonarQube Quality Gate.
6. Package the Spring Boot application.
7. Build a Docker image.
8. Push the image to AWS ECR.
9. Register a new ECS task definition revision and update the ECS service

## Tech stack

- **Application:** Java 21, Spring Boot
- **Build:** Maven
- **CI/CD:** Jenkins Pipeline
- **Code quality:** Checkstyle, SonarQube Quality Gate
- **Containerization:** Docker
- **Cloud registry:** AWS ECR
- **Cloud runtime:** AWS ECS
- **Infrastructure:** Terraform
- **Server configuration:** Ansible
- **Version control:** Git, GitHub

### Jenkins agent-based execution

The Jenkins pipeline runs on a dedicated Jenkins agent with the label `docker-aws-maven`.

The Jenkins controller is used only for orchestration, while the agent performs the actual CI/CD work:

- Maven build and tests
- Checkstyle and SonarQube analysis
- Docker image build and push to ECR
- ECS deployment

This keeps the Jenkins controller clean and makes the setup closer to a production-like CI/CD environment.

## Repository structure

- `src/` — Spring Boot application source code
- `Dockerfile` — Docker image definition
- `Jenkinsfile` — Jenkins CI/CD pipeline
- `data/` — keeps the required local data directory available when running the app outside Docker
- `pom.xml` — Maven project configuration
- `.gitignore` — ignored local and build files
- `README.md` — main project overview
- `scripts/` — helper scripts used by the CI/CD pipeline
- `scripts/deploy-ecs.sh` — ECS deployment script used by Jenkins to render the task definition, register a new ECS task definition revision, update the ECS service, and wait until the service becomes stable
- `docs/` — technical documentation
- `aws/` — AWS deployment templates
- `aws/task-definition-template.json` — ECS task definition template used by Jenkins during deployment
- `docs/screenshots/` — screenshots used as visual proof of the pipeline and deployment result
- `terraform/` — Terraform root module for the current AWS infrastructure
- `ansible/` — inventory, variables, and playbooks for the EC2 servers

## Run locally

Prerequisites:

- Java 21
- Maven 3.9+
- Git

The application expects a data directory in the project root during local execution. The repository keeps this directory with data/.gitkeep.

Clone the repository:

- `git clone https://github.com/yaromacarano/CICD-todoApp.git`
- `cd CICD-todoApp`

Run Maven verification:

- `mvn clean verify`

Start the application:

- `mvn spring-boot:run`

Application URL:

- `http://localhost:8080`

More local build details are documented in `docs/02-local-run.md`.

## Docker

Build the application artifact:

- `mvn clean package -DskipTests`

Build the Docker image:

- `docker build -t todo-app:v1.0 .`

Run the container:

- `docker run --rm -p 8080:8080 todo-app:v1.0`

More Docker details are documented in `docs/03-docker.md`.

## Screenshots and proof

Screenshots are stored in `docs/screenshots/` and cover the main proof points of the project:

- GitHub repository structure;
- successful Jenkins pipeline run;
- Jenkins stage view;
- SonarQube Quality Gate;
- Docker image in AWS ECR;
- AWS ECS service deployment;
- running ECS task;
- application running from the ECS deployment endpoint;
- new ECS task definition revision after deployment.

Screenshot naming and content are documented in `docs/screenshots/v1.1-ecs-task-revision-deployment`.

## Documentation

Detailed notes are kept in the `docs/` directory:

- `docs/01-project-overview.md` — project purpose, architecture, and DevOps workflow.
- `docs/02-local-run.md` — local build and application run instructions.
- `docs/03-docker.md` — Docker image build and container run notes.
- `docs/04-jenkins-pipeline.md` — Jenkins stages, tools, integrations, and environment values.
- `docs/05-aws-ecr-ecs.md` — AWS ECR and ECS deployment details.
- `docs/06-troubleshooting.md` — common issues and checks for Maven, Docker, Jenkins, SonarQube, ECR, and ECS.
- `docs/07-terraform-ansible.md` — Terraform and Ansible deployment instructions.
- `docs/screenshots/v1.1-ecs-task-revision-deployment` — screenshot list used as visual proof of pipeline and deployment results.

## Security

Secrets are not stored in this repository. Jenkins credentials and AWS access keys are managed outside the codebase through Jenkins Credentials and AWS IAM.

Screenshots committed to the repository must not expose tokens, passwords, access keys, or private infrastructure details.
