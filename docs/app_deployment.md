# Application deployment on AWS

The deployment of an application running on a local machine requires special care
when a deployment on a server is of interest. In this documentation we will go
through several crucial points that have to be taken into account.

But first we will talk about load balancer. What is it and why do we have to use
application load balancer, instead of classic load balancer, which is a default
option for AWS Elastic Beanstalk.

## Load Balancer and Reverse Proxy

Amazon uses Load Balancers to distribute traffic to multiple servers. It acts
as a reverse proxy. 

The reverse proxy is incorporated inside of the AWS network, and listens to requests
from outside.
It then forwards these requests to servers and listens again for responses.
This is provided by Nginx, which is configurable (and has to configured).

In AWS we have an option to use either Classic (default) Load Balancer or an
Application Load Balancer.

Classic Load Balancer operates on two levels:
    - request - dealing with higher level protocols (eg. HTTP)
    - connection - dealing with lower level protocols (eg. TCP, UDP) 

Application Load Balancer operates only on the request level.

Classic Load Balancer is older (2009) and is missing some features that are
possible with Application LB, such as redirecting HTTP traffic to HTTPS, which
is necessary in our case. 

https://blog.engineyard.com/application-load-balancer-vs-classic-load-balancer#:~:text=The%20Classic%20Load%20Balancer%20operates%20on%20both%20the%20request%20and%20connection%20levels.&text=A%20Classic%20Load%20Balancer%20is,application%2C%20you%20can%20use%20this.

Since the Classic Load Balancer is the default option in Elastic Beanstalk, we
have to specify it in the `main.tf` terraform file.

A simple block has to be added to the `aws\_elasic\_beanstalk\_environment`
resource:
```
setting {
  namespace = "aws:elasticbeanstalk:environment"
  name = "LoadBalancerType"
  value = "application"
}
```

## Application Environment

### Ports
Locally the application runs on some port (eg 5000). However this is not desired during
application deployment.

When a user requests a page (such as "https://alias.domain.com"), we would
want the application to return this exact response. 

The ports in `Dockerfile` (EXPOSE) and `docker-compose.yml` (or `Dockerrun.aws.json`) need to be set to 80 as well as
the port in the application. The application host should be set to `0.0.0.0`

### Nginx
The reverse proxy handles requests from users and provides responses from
servers. Thus it needs to know what should it listen to and how to forward
the responses.

The nginx configuration file is saved at `.platform/nginx/nginx.conf`

The most important part of the config file is the `server` block. Here we tell
nginx to listen to requests at port 80, which is a default HTTP port. 

The reason why port 443 (HTTPS) is not used instead is, that the communication
on AWS is secure and any HTTPS requests from outside should be first
terminated, so that the communication between servers on AWS is faster.
A step-by-step guide on how to do this is provided in a later section.

The only thing that we have to change in the configuration file is the
`proxy_set_header HOST` from `$host` to `alias.domain.com`. The rest of the
configuration file can be left as it is. 
This is an alias (created with Route53) to the Elastic Beanstalk environment which we use for our app.

## Elastic Beanstalk

In this section we briefly describe Elastic Beanstalks interface and
configuration options.

### Elastic Beanstalk Basics

In Elastic Beanstalk (EB) we distinguish the environment in which the
application runs and the application. The version of an application that is
currently running in the environment can be viewed by clicking on `Application
versions` under the application name in the left sidebar.

On the main page of an evironment, we see its name with an URL of the
environment. This is the url on which the application runs and in order to use
custom domain name, one has to create an alias to this URL with Route53. This
is described later in the subsection `Create an alias to Elastic Beanstalk
Environemnt with Route53`.

To configure the environment, go to Configuration under the name of the
environement in the left sidebar.
To edit the environment variables (not recommended), Click on `Edit` under the
`Software` tab.

Other tabs provide different configuration options, however the only one that
needs a change is the `Load Balancer` one (see subsection on terminating HTTPS).

## Route53
Route53 is a service for registering and managing domains.
To create an alias to an Elastic Beanstalk environment:

1. Under `Hosted zones` select a hosted zone
2. Click on `Create record` in the top right corner
3. Select `Simple routing` and click on `Next`
4. Select `Define simple record`
5. Fill in Record name
6. Under `Value/Route traffic to` choose `Alias to Elastic Beanstalk
   environment`
7. Under region choose your region (e.g. Europe (Frankfurt) [eu-central-1])
8. Choose an EB environment
9. Click on `Define simple record`
10. Click on `Create records`

## Terminate HTTPS traffic

As already mentioned, the communication on AWS is secure, so in order to make
it more efficient, it is unnecessary to use HTTPS requests and use basic HTTP
instead.
For this, AWS needs to terminate a HTTPS request "at the entrance". This can be
done in following way:

1. Go to `Configuration` under your environment name
2. Click on `Edit` under the `Load Balancer` tab
3. Under `Listeners` select `+ Add listener`
4. Choose:
    - Port: 443
    - Protocol: HTTPS
    - SSL Certificate: an active certificate saved in the AWS Certificate
      Manager
    - SSL policy: ELBSecurityPolicy-2016-08
5. Press `Add`
6. Press `Apply`

## Redirect HTTP traffic to HTTPS in EC2
To ensure that all traffic is secure:

1. Go to AWS EC2
2. Under `Load Balancing` on the left sidebar choose `Load Balancers`
3. Choose your Load Balancer (TIP: If you do not know which one is responsible for
   your EB environment, go through all of them and look at Tags tab)
4. Under `Listeners` click on `View/edit rules` for the `HTTP:80` listener
5. Click on the pencil (`Edit rules`) icon in the top bar
6. Click on the pencil (`Edit Rule`) to the left of your rule
7. Click on the trash bin icon under `Then`
8. Under `Add action` choose `Redirect to...`
9. Set the port number to 443
10. Click on the "check" icon
11. Click on `Update`
