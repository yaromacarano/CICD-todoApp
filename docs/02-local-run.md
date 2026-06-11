# Local Run Guide

## Purpose

This document describes how to build and run the application on a local machine.

Local execution checks the application before running the GitHub Actions workflow or building the Docker image.

## Prerequisites

- Java 21
- Maven 3.9+
- Git

Docker is only required for container testing. The application can be built and started without Docker.

## Clone repository

Run these commands:

- `git clone https://github.com/yaromacarano/CICD-todoApp.git`
- `cd CICD-todoApp`
- `git checkout github-actions`

## Local data directory

The application expects a data/ directory in the project root during local execution.

The repository keeps this directory with:

- `data/.gitkeep`

This makes local runs work from the repository root without creating the directory manually.

## Check Java

Command:

- `java -version`

Expected major version:

- `21`

## Check Maven

Command:

- `mvn -version`

Expected Maven version:

- `3.9.x` or newer

## Run verification

Command:

- `mvn clean verify`

This command performs the Maven verification flow:

- removes previous build output;
- compiles the project;
- runs tests configured in the project;
- verifies the Maven project state.

## Build JAR

Command:

- `mvn clean package`

The build artifact is created in:

- `target/`

The workflow uploads this artifact from:

- `target/*.jar`

The application artifact used in this project is:

- `target/todolist-app-1.0.0.jar`

## Run with Maven

Command:

- `mvn spring-boot:run`

Application URL:

- `http://localhost:8080`

## Run built JAR

Command:

- `java -jar target/todolist-app-1.0.0.jar`

Application URL:

- `http://localhost:8080`

## Stop application

Use `Ctrl + C` in the terminal where the application is running.

## Local verification checklist

Local verification checks:

- `java -version` shows Java 21;
- `mvn clean verify` completes successfully;
- `mvn clean package` creates the JAR file in `target/`;
- the application starts on port `8080`.
