# Deploy a Docker-ized Flask app to Elastic Beanstalk with Terraform

This guide shows how to deploy a Docker-ized flask app (or any other if you can provide
 working `Dockerfile` and `docker-compose.yml` files) to elastic beanstalk. To
provision the resources we will use `Terraform` and we will show how to create
a CI/CD pipeline inside AWS using `CodePipeline`, `CodeBuild` and `CodePipeline` services.

This can be an extremely painful proces, so I hope this will ease it up for you
:)

---
### 1. Create a repository in AWS CodeCommit
This step is relatively straightforward, simply go to AWS `CodeCommit` service,
and create a new repository.

### 2. Add files to your application root folder
Clone this repo and copy these files at the root of your application:
- main.tf - main terraform file - no changes are necessary to this file
- backend - file with backend info passed at `terraform init`
- variables.tf - terraform default variables
- variables.tfvars - branch/project specific vars
- buildspec.yml
- Dockerfile
- docker-compose.yml
- .platform/ - a folder with nginx config file

### 3. Modify the files to suit your application
- see `docs/pipeline\_files.md`

### 4. Add, Commit, Push
- Push your local repo to `AWS CodeCommit`

### 5. Create Build Project and Pipeline
- see `pipeline.md`
---
### Additional info regarding application deployment
- see `docs/app\_deployment.md`

---
Feel free to open an issue if there is something wrong with the files or your
project.


