# How to create a Pipeline in AWS

The AWS CodePipeline is responsible for automatic deployment of an application to
AWS Elastic Beanstalk once a change occurs in the repository.

## 2. Build Project
The pipeline is composed of two stages. In the first (called Source) AWS
listens to the changes in the repository and in the second stage the project is
built according to instructions specified in a `buildspec.yml` file.

Before putting everything together, we need to create a build project. To do
so, head to the AWS CodeBuild console and press the `Create build project` button in the
top right corner.

- **Project configuration**: Type in the `Project name`.
- **Source**: 
    - Choose `AWS CodeCommit` (default) as the Source provider
    - Choose desired repository from the rollout menu
    - Choose a branch the pipeline should listen to
- **Environment**
    - Choose `Managed image`(default) for the Environment image option
    - From the list of operating system choose `Ubuntu`
    - Set Runtime to `Standard`
    - Set Image to `aws/codebuild/standard:4.0`
    - Set Image version to `Always use the latest image for this runtime
      version`
    - Set Environment type to `Linux`
    - Enable the Privileged flag to allow building docker images
    - Set Service role to `Existing service role`
    - Set Role ARN to the `codebuilder` role

Leave rest of the page to defaults.
Click on `Create build project`

## 3. Pipeline
Under AWS CodePipeline select `Pipelines` and click on `Create pipeline` in the
top right corner.

- **Choose Pipeline settings**
    - Choose a pipeline name
    - Set service role to `Existing service role`
    - set Role name to `codepiper`
    - click on `next`
- **Add Source stage**
    - Set Source provider to `AWS CodeCommit`
    - Pick a Repository name from the menu
    - Pick a Branch from the menu
    - click on `next`
- **Add build stage**
    - Set Build provider to `AWS CodeBuild`
    - Set Region to `Europe (Frankfurt)`
    - choose the name of the build project created in previous part
    - Input these environment variables by clicking on `Add environment variable`
        - `TFVARS`: example.tfvars (eg. variables-production.tfvars) - see repo
        - `CONFIG`: Name of the secret in the Secrets Manager
        - `SECRET_NAME`: Key to parse the secret in json file (can be the same
          as `CONFIG`)
        - `ECR`: Name of the repository where the Docker image should be
          stored, e.g. cnweb_production
        - `BACKEND`: e.g. backed-production
        - `HOST`: URL at which the app will runs (set in Route53)
    - click on `next`
    - click on `skip deploy stage`
    - click on `Create pipeline`

