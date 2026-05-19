# CI/CD Todo App — GitLab CI Portfolio Project

Java Spring Boot Todo application with a GitLab CI/CD pipeline, Docker image build, SonarQube quality checks, AWS ECR image publishing, and AWS ECS deployment.

This branch documents the GitLab CI implementation of the project. The application code is used as a practical base for demonstrating build automation, containerization, code quality checks, registry publishing, and cloud deployment.

## Architecture

GitLab Repository → GitLab CI Pipeline → Maven → SonarQube → Docker → AWS ECR → AWS ECS Service

The pipeline performs these steps:

1. Run Maven tests.
2. Run Checkstyle analysis.
3. Build the Spring Boot application artifact.
4. Send code analysis to SonarQube.
5. Validate the SonarQube Quality Gate.
6. Build a Docker image.
7. Push the image to AWS ECR.
8. Create a new ECS task definition revision.
9. Update the ECS service to use the new revision.

## Tech stack

- **Application:** Java 17, Spring Boot
- **Build:** Maven
- **CI/CD:** GitLab CI/CD
- **CI/CD runner:** Self-hosted GitLab Runner on AWS EC2
- **Code quality:** Checkstyle, SonarQube Quality Gate
- **Containerization:** Docker, Docker-in-Docker
- **Cloud registry:** AWS ECR
- **Cloud runtime:** AWS ECS on Fargate
- **Deployment automation:** AWS CLI, ECS task definition template
- **Version control:** Git, GitLab, GitHub portfolio mirror

## Repository structure

- `src/` — Spring Boot application source code
- `Dockerfile` — Docker image definition
- `.gitlab-ci.yml` — GitLab CI/CD pipeline definition
- `aws/` — AWS deployment templates
- `aws/task-definition-template.json` — ECS task definition template used during deployment
- `scripts/` — deployment scripts used by the pipeline
- `scripts/deploy-ecs.sh` — ECS deployment script
- `data/` — keeps the required local data directory available when running the app outside Docker
- `pom.xml` — Maven project configuration
- `.gitignore` — ignored local and build files
- `README.md` — main project overview
- `docs/` — technical documentation
- `docs/screenshots/gitlab-ci/` — screenshots used as visual proof of the GitLab CI pipeline and deployment result

## Run locally

Prerequisites:

- Java 17
- Maven 3.9+
- Git

Clone the repository:

- `git clone https://github.com/yaromacarano/CICD-todoApp.git`
- `cd CICD-todoApp`
- `git checkout gitlab-ci`

The application expects a `data/` directory in the project root during local execution. The repository keeps this directory with `data/.gitkeep`.

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

- `docker build -t todo-app:gitlab-ci .`

Run the container:

- `docker run --rm -p 8080:8080 todo-app:gitlab-ci`

More Docker details are documented in `docs/03-docker.md`.

## GitLab CI/CD

The GitLab pipeline is defined in `.gitlab-ci.yml`.

Main stages:

1. `test`
2. `build`
3. `sonarqube-check`
4. `push`
5. `deploy`

The deployment flow uses `scripts/deploy-ecs.sh`. The script creates a task definition file from `aws/task-definition-template.json`, registers a new ECS task definition revision, and updates the ECS service.

More pipeline details are documented in `docs/04-gitlab-ci-pipeline.md`.

The GitLab CI pipeline runs on a self-hosted GitLab Runner hosted on an AWS EC2 instance.

## Screenshots and proof

Screenshots are stored in `docs/screenshots/gitlab-ci/` and cover the main proof points of the project:

- GitLab repository and branch structure;
- `.gitlab-ci.yml` pipeline file;
- successful GitLab pipeline run;
- GitLab pipeline stages;
- SonarQube project and Quality Gate;
- Docker image in AWS ECR;
- new ECS task definition revision;
- ECS service updated after GitLab deployment;
- running ECS task;
- application running from the ECS deployment endpoint.

Screenshot naming and content are documented in `docs/screenshots/gitlab-ci/README.md`.

## Documentation

Detailed notes are kept in the `docs/` directory:

- `docs/01-project-overview.md` — project purpose, architecture, and DevOps workflow.
- `docs/02-local-run.md` — local build and application run instructions.
- `docs/03-docker.md` — Docker image build and container run notes.
- `docs/04-gitlab-ci-pipeline.md` — GitLab CI stages, variables, rules, and deployment flow.
- `docs/05-aws-ecr-ecs.md` — AWS ECR and ECS deployment details.
- `docs/06-troubleshooting.md` — common issues and checks for Maven, Docker, GitLab CI, SonarQube, ECR, and ECS.
- `docs/screenshots/gitlab-ci/` — screenshot list used as visual proof of pipeline and deployment results.

## Security

Secrets are not stored in this repository. GitLab CI/CD variables and AWS IAM are used for credentials and environment-specific values.

Screenshots committed to the repository must not expose tokens, passwords, access keys, private infrastructure details, or personal data.
