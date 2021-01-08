variable "profile" {
  description = "Name of your profile"
  default = "profile"
}

variable "region" {
  default     = "eu-central-1"
  description = "Defines where your app should be deployed"
}

variable "application_name" {
  description = "Name of your application"
  default = "app-name"
}

variable "iam_role_name" {
  default = "app-iamrole"
  description = "iam role name"
}

variable "instance_profile_name" {
  default = "app-profile"
  description = "instance profile name"
}

variable "application_environment" {
  description = "Deployment stage e.g. 'staging', 'production', 'test', 'integration'"
  default = "app-env"
}

variable "instance_type" {
  default = "t2.micro"
  description = "EC2 instance type"
}

variable "load_balancer_instances" {
  default = 2
  description = "Maximum number of instances in load balanced environment"
}

variable "load_balancer_type" {
  default = "application"
  description = "Type of the load balancer"
}
