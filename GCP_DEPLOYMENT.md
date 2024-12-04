# GCP Deployment Guide for FastAPI with CI/CD

This guide explains how to deploy a **Dockerized FastAPI application** to **Google Cloud Run (GCR)** with CI/CD integration using GitHub Actions. It covers creating a development container, deploying the application to GCR, and setting up CI/CD for automation. 

For a detailed step-by-step walkthrough, you can also watch the tutorial video:  
[Deploy FastAPI to Google Cloud Run with CI/CD](https://www.youtube.com/watch?v=DQwAX5pS4E8&t=1059s)

---

## Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Steps to Deploy](#steps-to-deploy)
    - [1. Create a Development Container](#1-create-a-development-container)
    - [2. Build a FastAPI Application](#2-build-a-fastapi-application)
    - [3. Deploy to Google Cloud Run](#3-deploy-to-google-cloud-run)
    - [4. Set Up CI/CD with GitHub Actions](#4-set-up-cicd-with-github-actions)
4. [Tips](#tips)
5. [Outcome](#outcome)

---

## Overview

This deployment process involves:

1. Setting up a **development container** to isolate the development environment.
2. Building and testing a **FastAPI application**.
3. Deploying the application to **Google Cloud Run** using Dockerized containers.
4. Setting up **CI/CD** with GitHub Actions to automate deployment on code updates.

---

## Prerequisites

Ensure you have the following installed and set up:

- **Docker Desktop**
- **VS Code** with the following extensions:
  - Dev Containers
  - Docker
- A basic understanding of:
  - Docker and CLI commands
  - Git and GitHub
  - FastAPI and Python development
- A Google Cloud Platform (GCP) account with billing enabled.

---

## Steps to Deploy

### 1. Create a Development Container

1. **Set up the container**:
   - Create a folder `devcontainer` at the root of your project.
   - Add a `devcontainer.json` file specifying:
     - Container name
     - Dockerfile reference
     - Port forwarding configurations
     - VS Code extensions

2. **Create a Dockerfile**:
   - Use a slim Python image (e.g., `python:3.12-slim`) to keep the container lightweight.

3. **Open the container in VS Code**:
   - Press `Shift + Cmd + P` > "Dev Containers: Reopen in Container."
   - Test the container by ensuring tools like `git`, `curl`, and `python` are installed.

---

### 2. Build a FastAPI Application

1. Set up the project directory and add necessary files for a basic FastAPI app.
2. Install required Python packages and resolve import warnings.
3. Test the FastAPI app locally:
   - Run the app and ensure the endpoints work (e.g., `hello world`).
   - Use the debugger in VS Code to verify functionality.

---

### 3. Deploy to Google Cloud Run

1. **Install gcloud CLI**:
   - Update the Dev Container's Dockerfile to include gcloud installation.
   - Rebuild the container and authenticate with GCP using:
     ```bash
     gcloud init
     ```

2. **Set up the GCP project**:
   - Create a GCP project and enable **Artifact Registry**.
   - Use the registry to store Docker images.

3. **Build and push the Docker image**:
   - Add a new production Dockerfile.
   - Create a `cloudbuild.yaml` file for deployment instructions.
   - Run the build command to push the image to the Artifact Registry.

4. **Deploy to GCR**:
   - Add a `service.yaml` file specifying deployment configurations.
   - Deploy the app using:
     ```bash
     gcloud run deploy
     ```
   - Update the service policy to make the app publicly accessible.

---

### 4. Set Up CI/CD with GitHub Actions

1. **Create a GCP service account**:
   - Generate a service account with the necessary permissions.
   - Download the service account key and add it as a GitHub secret (`GCP_SA_KEY`).

2. **Configure GitHub Actions**:
   - Add a `.github/workflows` folder with a `ci-cd.yaml` file.
   - Include instructions to:
     - Authenticate with GCP
     - Build and deploy the app to GCR

3. **Test automation**:
   - Push a change to the main branch and verify:
     - GitHub Actions triggers the build.
     - The new app version is deployed automatically.
   - Validate changes by accessing the updated live endpoint.

---

## Tips

- **Authentication**:
  - Ensure GCP and GitHub permissions are correctly set.
  - Adjust permissions for service accounts as needed.

- **Debugging**:
  - Check logs in GitHub Actions and GCP for errors during deployment.

- **References**:
  - Watch the [YouTube tutorial](https://www.youtube.com/watch?v=DQwAX5pS4E8) for a detailed walkthrough.

---

## Outcome

By following this guide, you’ll have:

1. A **Dockerized FastAPI application** running on Google Cloud Run.
2. **CI/CD automation** to deploy updates with every push to the main branch.

This ensures a streamlined and efficient workflow for deploying Python-based APIs to the cloud.
