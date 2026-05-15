# CI/CD Todo App — GitHub Actions DevOps Portfolio Project

Java Spring Boot Todo application with a GitHub Actions CI/CD workflow, Maven build, Checkstyle analysis, SonarQube quality checks, Docker image publishing to AWS ECR, and AWS ECS deployment through a new task definition revision.

This branch demonstrates the same DevOps delivery flow as the Jenkins version, but implemented with GitHub Actions as the CI/CD platform.

## Architecture

GitHub Repository → GitHub Actions → Maven → Checkstyle → SonarQube → Docker → AWS ECR → AWS ECS

The workflow performs these steps:

1. Fetch source code from GitHub.
2. Set up Java 17 on the GitHub-hosted runner.
3. Run Maven verification.
4. Run Checkstyle analysis.
5. Build the Spring Boot application.
6. Run SonarQube analysis and wait for the Quality Gate.
7. Upload the build artifact.
8. Configure AWS credentials.
9. Build and push the Docker image to AWS ECR.
10. Render a new ECS task definition with the new image.
11. Deploy the ECS task definition to the ECS service.
12. Wait until the ECS service becomes stable.

## Tech stack

- **Application:** Java 17, Spring Boot
- **Build:** Maven
- **CI/CD:** GitHub Actions
- **Code quality:** Checkstyle, SonarQube Quality Gate
- **Containerization:** Docker
- **Cloud registry:** AWS ECR
- **Cloud runtime:** AWS ECS Fargate
- **Version control:** Git, GitHub

## Repository structure

- `src/` — Spring Boot application source code
- `.github/workflows/deploy.yml` — GitHub Actions CI/CD workflow
- `data/` — keeps the required local data directory available when running the app outside Docker
- `aws/task-definition-template.json` — ECS task definition template used during deployment
- `Dockerfile` — Docker image definition
- `pom.xml` — Maven project configuration
- `README.md` — main project overview
- `docs/` — technical documentation
- `docs/screenshots/` — screenshots used as visual proof of the workflow and deployment result

## Branch purpose

This branch is focused on the GitHub Actions implementation.

- `main` — Jenkins-based CI/CD implementation
- `github-actions` — GitHub Actions-based CI/CD implementation

The application and AWS deployment target remain the same. The CI/CD engine is different.

## Run locally

Prerequisites:

- Java 17
- Maven 3.9+
- Git

The application expects a data directory in the project root during local execution. The repository keeps this directory with data/.gitkeep.

Clone the repository:

- `git clone https://github.com/yaromacarano/CICD-todoApp.git`
- `cd CICD-todoApp`
- `git checkout github-actions`

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

- `docker build -t todo-app:github-actions .`

Run the container:

- `docker run --rm -p 8080:8080 todo-app:github-actions`

More Docker details are documented in `docs/03-docker.md`.

## GitHub Actions workflow

The workflow is defined in:

- `.github/workflows/deploy.yml`

It runs on:

- push to `github-actions`
- pull request to `github-actions`
- manual start through `workflow_dispatch`

Pull requests run build, tests, Checkstyle, SonarQube analysis, and artifact upload.

Deployment steps run only for direct pushes to the `github-actions` branch.

## Screenshots and proof

Screenshots are stored in `docs/screenshots/github-actions/` and cover the main proof points of the project:

- GitHub Actions workflow file;
- successful GitHub Actions workflow run;
- workflow job steps;
- SonarQube project and Quality Gate;
- Docker image in AWS ECR;
- ECS task definition revision created by the workflow;
- ECS service updated to the new task definition revision;
- application running from the ECS deployment endpoint.

Screenshot naming and content are documented in `docs/screenshots/github-actions/README.md`.

## Documentation

Detailed notes are kept in the `docs/` directory:

- `docs/01-project-overview.md` — project purpose, architecture, and DevOps workflow.
- `docs/02-local-run.md` — local build and application run instructions.
- `docs/03-docker.md` — Docker image build and container run notes.
- `docs/04-github-actions-workflow.md` — GitHub Actions workflow, secrets, variables, and deployment stages.
- `docs/05-aws-ecr-ecs.md` — AWS ECR and ECS deployment details.
- `docs/06-troubleshooting.md` — common issues and checks for Maven, Docker, GitHub Actions, SonarQube, ECR, and ECS.
- `docs/screenshots/github-actions/README.md` — screenshot list used as visual proof of workflow and deployment results.

## Security

Secrets are not stored in this repository. AWS access keys and SonarQube tokens are managed through GitHub Actions Secrets.

Environment-specific values such as AWS region, ECR repository name, ECS cluster, ECS service, and container name are managed through GitHub Actions Variables.

Screenshots committed to the repository must not expose tokens, passwords, access keys, or private infrastructure details.
