## buildspec.yml

The instructions for project building are stored in the `buildspec.yml` file.
The build process consists of three stages.

The buildspec file is ready to go. 

If you have a domain registered in Route53 and would like to create an alias
record to the elastic beanstalk environment, uncomment the line:
`sed -i "s/HOST/<your_alias.com>/" .platform/nginx/nginx.conf` and insert your
the alias url registered in Route53.

However there is also an option to push the
docker image to ECR. To do this, uncomment all lines in buildspec. Make sure
that you have created an `ECR` repository and know its name together with your
account number. You also have to change the name of the file
`_Dockerrun.aws.json` to `Dockerrun.aws.json`.

### \_Dockerrun.aws.json
If you wish to push your Docker image to ECR and pull it from it, change the
name of this file by removing the underscore.

Inside of the file, replace:
    - `<account_number>` with your account number
    - `region` with the region name (eg eu-central-1)

## main.tf
No changes are necessary in the `main.tf` terraform file. This file contains
all resources provisioned by terraform on AWS.

It creates a new Elastic Beanstalk environment and application and saves the
terraform state into a separate S3 bucket. This makes the deployment process
much faster, since the resources that already exist will not be rebuilt.

## backend
specify the S3 bucket where terraform will save its state file.

Replace <region> with your region

## variables.tf
Default variables passed to `terraform apply`

## variables.tfvars
Branch/Project specific variables passed to terraform apply

## Dockerfile and docker-compose.yml

You can either use the templates we provide or use your own. Just make sure
that your app will run on `host=0.0.0.0` and `port=80` and the ports in
`docker-compose.yml` are also set to 80.
