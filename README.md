# CI/CD Todo App — DevOps Portfolio Project

Java Spring Boot Todo application with a Jenkins CI/CD pipeline, Docker image build, SonarQube quality checks, AWS ECR image publishing, and AWS ECS task definition revision deployment.

The application code is used as a base for demonstrating a practical DevOps workflow around build automation, containerization, quality control, and cloud deployment.

## Architecture

GitHub Repository → Jenkins Pipeline → AWS ECR → AWS ECS Service

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

- **Application:** Java 17, Spring Boot
- **Build:** Maven
- **CI/CD:** Jenkins Pipeline
- **Code quality:** Checkstyle, SonarQube Quality Gate
- **Containerization:** Docker
- **Cloud registry:** AWS ECR
- **Cloud runtime:** AWS ECS
- **Version control:** Git, GitHub

## Repository structure

- `src/` — Spring Boot application source code
- `Dockerfile` — Docker image definition
- `Jenkinsfile` — Jenkins CI/CD pipeline
- `pom.xml` — Maven project configuration
- `.gitignore` — ignored local and build files
- `README.md` — main project overview
- `docs/` — technical documentation
- `aws/` — AWS deployment templates
- `aws/task-definition-template.json` — ECS task definition template used by Jenkins during
- `docs/screenshots/` — screenshots used as visual proof of the pipeline and deployment result

## Run locally

Prerequisites:

- Java 17
- Maven 3.9+
- Git

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
- SonarQube project and Quality Gate;
- Docker image in AWS ECR;
- AWS ECS service deployment;
- running ECS task;
- application running from the ECS deployment endpoint.
- new ECS task definition revision after deployment

Screenshot naming and content are documented in `docs/screenshots/`.

## Documentation

Detailed notes are kept in the `docs/` directory:

- `docs/01-project-overview.md` — project purpose, architecture, and DevOps workflow.
- `docs/02-local-run.md` — local build and application run instructions.
- `docs/03-docker.md` — Docker image build and container run notes.
- `docs/04-jenkins-pipeline.md` — Jenkins stages, tools, integrations, and environment values.
- `docs/05-aws-ecr-ecs.md` — AWS ECR and ECS deployment details.
- `docs/06-troubleshooting.md` — common issues and checks for Maven, Docker, Jenkins, SonarQube, ECR, and ECS.
- `docs/screenshots/` — screenshot list used as visual proof of pipeline and deployment results.

## Security

Secrets are not stored in this repository. Jenkins credentials and AWS access keys are managed outside the codebase through Jenkins Credentials and AWS IAM.

Screenshots committed to the repository must not expose tokens, passwords, access keys, or private infrastructure details.
