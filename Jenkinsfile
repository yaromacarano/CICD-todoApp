pipeline {
    agent any
    tools {
        maven "MAVEN3.9"
        jdk "JDK17"
    }


    environment {
        registryCredential = "ecr:us-east-1:awscreds"
        imageName = "551647579168.dkr.ecr.us-east-1.amazonaws.com/todo-appimg"
        vprofileRegistry = "https://551647579168.dkr.ecr.us-east-1.amazonaws.com"
        service = "todo-ecs-service"
        cluster = "newcluster"
    }
  stages {
   
        stage('Fetch code') {
            steps {
               git branch: 'main', url: 'https://github.com/yaromacarano/TodoListApp-Java-SpringBoot.git'
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
              docker.withRegistry( vprofileRegistry, registryCredential ) {
                dockerImage.push("$BUILD_NUMBER")
                dockerImage.push('latest')
              }
            }
          }
        }

         stage('Deploy to ecs') {
          steps {
            withAWS(credentials: 'awscreds', region: 'us-east-1') {
            sh "aws ecs update-service --cluster ${cluster} --service ${service} --force-new-deployment"
               }
          }
        }


  }
}
