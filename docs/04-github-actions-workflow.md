# GitHub Actions Workflow

## Purpose

The workflow in `.github/workflows/deploy.yml` validates the application and deploys approved builds to Amazon ECS.

It uses GitHub-hosted `ubuntu-latest` runners. Every job receives a new temporary runner, so the application artifact is transferred between jobs through GitHub Actions artifacts.

## Workflow overview

```text
Checkout → Java 21 → Maven build, tests and Checkstyle → SonarQube Cloud
         → Upload JAR → Download JAR → AWS authentication
         → Docker image → ECR → ECS task definition → ECS deployment
```

## Triggers

The workflow supports three events:

| Event | `build-test-scan` | `deploy` |
| --- | --- | --- |
| Push to `github-actions` | Runs | Runs |
| Pull request to `github-actions` | Runs | Skipped |
| `workflow_dispatch` on `github-actions` | Runs | Runs |

The deployment condition is:

```yaml
if: github.ref == 'refs/heads/github-actions' && github.event_name != 'pull_request'
```

This prevents pull requests from changing AWS resources. It also means that a manual run deploys when `github-actions` is selected.

## Permissions and environment

The workflow grants the GitHub token read-only repository access:

```yaml
permissions:
  contents: read
```

The `deploy` job is assigned to the `production` GitHub environment. This makes it possible to add environment protection rules or keep deployment secrets at environment scope if required.

## Job 1: `build-test-scan`

This job validates the application before any AWS deployment.

### Checkout

`actions/checkout` downloads the repository. `fetch-depth: 0` provides the complete Git history required for accurate SonarQube Cloud analysis.

### Java setup

`actions/setup-java` installs Temurin Java 21 and enables the Maven dependency cache.

### Build, test, Checkstyle, and analysis

The current workflow runs one Maven command:

```bash
mvn clean verify \
  checkstyle:checkstyle \
  org.sonarsource.scanner.maven:sonar-maven-plugin:5.5.0.6356:sonar \
  -Dsonar.organization=SONAR_ORGANIZATION \
  -Dsonar.projectKey=SONAR_PROJECT_KEY \
  -Dsonar.junit.reportPaths=target/surefire-reports \
  -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml \
  -Dsonar.qualitygate.wait=true
```

The real organization and project keys are loaded from GitHub Variables. The authentication token is loaded from the `SONAR_TOKEN` secret.

`sonar.qualitygate.wait=true` keeps the job running until SonarQube Cloud returns the Quality Gate result. If the gate fails, the job fails and deployment does not start.

### Artifact upload

The completed JAR is uploaded with:

| Setting | Value |
| --- | --- |
| Artifact name | `todolist-app-1.0.0` |
| Source path | `target/*.jar` |

## Job 2: `deploy`

The second job has `needs: build-test-scan`, so it starts only after the validation job succeeds.

### Artifact download

Because this job runs on a different runner, it downloads `todolist-app-1.0.0` into `target/`. The Dockerfile can then copy the JAR into the image.

### AWS authentication

`aws-actions/configure-aws-credentials` uses:

- `AWS_ACCESS_KEY_ID` from GitHub Secrets;
- `AWS_SECRET_ACCESS_KEY` from GitHub Secrets;
- `AWS_REGION` from GitHub Variables.

The credentials belong to an AWS IAM identity with permission to push to ECR, register an ECS task definition, update the ECS service, and pass the ECS execution role.

### ECR image

The workflow logs in to ECR, builds the Docker image, and tags it with the workflow run number:

```text
ECR_REGISTRY/ECR_REPOSITORY:GITHUB_RUN_NUMBER
```

The complete image URI is saved as a step output for the next step.

### ECS task definition

`aws-actions/amazon-ecs-render-task-definition` reads:

```text
aws/task-definition-template.json
```

It replaces `IMAGE_URI_PLACEHOLDER` for the container named by `CONTAINER_NAME`.

### ECS deployment

`aws-actions/amazon-ecs-deploy-task-definition` registers the rendered task definition and updates:

- the cluster from `CLUSTER`;
- the service from `SERVICE`.

`wait-for-service-stability: true` keeps the job running until ECS reports that the deployment is stable.

## Required GitHub settings

### Secrets

| Name | Used by |
| --- | --- |
| `SONAR_TOKEN` | SonarQube Cloud analysis |
| `AWS_ACCESS_KEY_ID` | AWS deployment |
| `AWS_SECRET_ACCESS_KEY` | AWS deployment |

### Variables

| Name | Purpose |
| --- | --- |
| `SONAR_ORGANIZATION` | SonarQube Cloud organization key |
| `SONAR_PROJECT_KEY` | SonarQube Cloud project key |
| `AWS_REGION` | Region containing ECR and ECS |
| `ECR_REPOSITORY` | ECR repository name |
| `CONTAINER_NAME` | Container name in the task definition |
| `SERVICE` | ECS service name |
| `CLUSTER` | ECS cluster name |

The workflow does not use `SONAR_HOST_URL`. SonarQube Cloud is the analysis service, so no self-hosted SonarQube server or EC2 instance is required.

## Pull request note

GitHub does not provide repository secrets to workflows created from untrusted forks. A pull request opened from a fork may therefore be unable to run the SonarQube Cloud step. This protects the secret from code controlled outside the repository.

## Successful run

A complete deployment confirms that:

- the project builds and tests on a clean runner;
- Checkstyle and SonarQube Cloud analysis complete;
- the Quality Gate passes;
- the JAR is shared correctly between the two jobs;
- the Docker image is pushed to ECR;
- a new ECS task definition revision is registered;
- the ECS service becomes stable with the new application image.

## References

- [GitHub Actions workflow syntax](https://docs.github.com/actions/using-workflows/workflow-syntax-for-github-actions)
- [SonarQube Cloud with GitHub Actions](https://docs.sonarsource.com/sonarqube-cloud/analyzing-source-code/ci-based-analysis/github-actions-for-sonarcloud)
