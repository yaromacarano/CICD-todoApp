pipeline {
    agent any
    tools {
        maven "MAVEN3.9"
        jdk "JDK17"
    }


    environment {
        registryCredential = "ecr:us-east-1:awscreds"
        imageName = credentials('ecr-image-name')
        Registry = "https://551647579168.dkr.ecr.us-east-1.amazonaws.com"
        service = "todo-ecs-service"
        cluster = "newcluster"
        taskDefinition = "todo-task"
        containerName = "todo"
    }
  stages {

        stage('Fetch code') {
            steps {
               git branch: 'main', url: 'https://github.com/yaromacarano/CICD-todoApp.git'
            }

        }

        stage('UNIT TEST') {
            steps{
                sh 'mvn clean verify'
            }
        }

        stage('Checkstyle Analysis') {
            steps{
                sh 'mvn checkstyle:checkstyle'
            }
        }

        stage("Sonar Code Analysis") {
            environment {
                scannerHome = tool 'sonar8.0'
            }
            steps {
              withSonarQubeEnv('sonarserver') {
                sh """${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=todo-sonar \
                   -Dsonar.projectName=todo-sonar \
                   -Dsonar.projectVersion=1.0 \
                   -Dsonar.sources=src/ \
                   -Dsonar.java.binaries=target/classes/ \
                   -Dsonar.junit.reportPath=target/surefire-reports/ \
                   -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml"""
              }
            }
        }

        stage("Quality Gate") {
            steps {
              timeout(time: 1, unit: 'HOURS') {
                waitForQualityGate abortPipeline: true
              }
            }
          }

        stage('Build'){
            steps{
               sh 'mvn package -DskipTests'
            }

            post {
               success {
                  echo 'Now Archiving it...'
                  archiveArtifacts artifacts: '**/target/todolist-app-1.0.0.jar'
               }
            }
        }

        stage('Build App Image') {
          steps {

            script {
                dockerImage = docker.build( imageName + ":$BUILD_NUMBER", "./")
                }
          }

        }

        stage('Upload App Image') {
          steps{
            script {
              docker.withRegistry( Registry, registryCredential ) {
                dockerImage.push("$BUILD_NUMBER")
                dockerImage.push('latest')
              }
            }
          }
        }

         stage('Deploy to ECS') {
           steps {
            withAWS(credentials: 'awscreds', region: 'us-east-1') {
            sh '''
                IMAGE_URI="${imageName}:${BUILD_NUMBER}"

                sed "s|IMAGE_URI_PLACEHOLDER|$IMAGE_URI|g" aws/task-definition-template.json > task-definition.json

                NEW_TASK_DEF_ARN=$(aws ecs register-task-definition \
                    --cli-input-json file://task-definition.json \
                    --query 'taskDefinition.taskDefinitionArn' \
                    --output text)

                aws ecs update-service \
                    --cluster ${cluster} \
                    --service ${service} \
                    --task-definition $NEW_TASK_DEF_ARN

                aws ecs wait services-stable \
                    --cluster ${cluster} \
                    --services ${service}

                echo "Deployed image: $IMAGE_URI"
                echo "Task definition: $NEW_TASK_DEF_ARN"
            '''
           }
        }
     }


  }
}
