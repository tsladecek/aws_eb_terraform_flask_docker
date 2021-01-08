# inspired by https://github.com/cloudposse/terraform-aws-elastic-beanstalk-environment

# Configure AWS Credentials & Region
provider "aws" {
  profile = var.profile
  region  = var.region
}

# Configure folder where terraform holds the state
terraform {
  backend "s3" {}
}

# S3 Bucket for storing Elastic Beanstalk task definitions
resource "aws_s3_bucket" "ng_beanstalk_deploys" {
  bucket = "${var.application_name}-deployments"
}

# upload zipped folder to S3
resource "aws_s3_bucket_object" "file_upload" {
  bucket = aws_s3_bucket.ng_beanstalk_deploys.bucket
  key    = "latest.zip"
  source = "latest.zip"
}

resource "aws_iam_role" "ng_beanstalk_ec2" {
  name = var.iam_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# elastic beanstalk environment must have instance profile associated with it
resource "aws_iam_instance_profile" "ng_beanstalk_ec2" {
  name  = var.instance_profile_name
  role = aws_iam_role.ng_beanstalk_ec2.name
}

# Beanstalk Application
resource "aws_elastic_beanstalk_application" "ng_beanstalk_application" {
  name        = var.application_name
}

# Beanstalk Environment
resource "aws_elastic_beanstalk_environment" "ng_beanstalk_application_environment" {
  name                = var.application_environment
  application         = aws_elastic_beanstalk_application.ng_beanstalk_application.name
  tier                = "WebServer"
  solution_stack_name = "64bit Amazon Linux 2 v3.1.0 running Docker"

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name = "LoadBalancerType"
    value = var.load_balancer_type
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"

    value = var.instance_type
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"

    value = var.load_balancer_instances
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.ng_beanstalk_ec2.name
  }

}

# application version
resource "aws_elastic_beanstalk_application_version" "latest" {
  name = "latest.zip"
  application = aws_elastic_beanstalk_application.ng_beanstalk_application.name
  bucket = aws_s3_bucket.ng_beanstalk_deploys.bucket
  key = "latest.zip"
}

output "env_name" {
  value = aws_elastic_beanstalk_environment.ng_beanstalk_application_environment.name
}
