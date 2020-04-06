# Trading Post Ops

This repo deploys the [Trading Post](https://github.com/cheuklau/trading-post) website.

## Infrastructure v1.0

Infrastructure v1.0 gets the initial version of the app ready for testing. Everything is running on a single server.

### Dependencies

- Packer

### Build Instructions

- Register an elastic IP (EIP) on AWS
- Register AWS Route53 domain name `mtgtradingpost.com`
- A hosted zone is automatically created for `mtgtradingpost.com`
- Create a record set pointing `mtgtradingpost.com` to the EIP
- Export AWS secret and access keys as environment variables for Terragrunt to use:
```
export AWS_ACCESS_KEY_ID=<access key>
export AWS_SECRET_ACCESS_KEY=<secret key>
```
- Use Packer to build the monolith Amazon Machine Image (AMI):
```
cd v1/packer
packer build packer.json
```
- Spin up an EC2 server with the created AMI
- Modify the Security Group to allow SSH/22 inbound from your IP and HTTP/80 inbound from you IP and all of the tester IPs
- Associate the EIP to the EC2 server
- SSH into the EC2 server using the EIP
- Start Apache server:
```
sudo a2ensite FlaskApp
sudo service apache2 restart
```

## Infrastructure v2.0

### Dependencies

- Packer
- Terraform
- Terragrunt

### Build Instructions

- Export AWS secret and access keys as environment variables for Terragrunt to use:
```
export AWS_ACCESS_KEY_ID=<access key>
export AWS_SECRET_ACCESS_KEY=<secret key>
```
- Use Packer to build the front-end AMI:
```
cd v2/packer
packer build packer.json
```
Note: CircleCI is already set up to deploy the AMI with every change to the application [repo](https://github.com/cheuklau/trading-post).
- Deploy RDS
```
cd v2/terragrunt/dev/rds
terragrunt apply --terragrunt-source-update
```
Note: Running Terragrunt for the first time creates DynamoDB locking table and S3 bucket to store the Terraform state. It will also output the RDS endpoint which will be used by the Flask front-end.
- Deploy ASG for Flask Front End
```
cd v2/terragrunt/dev/asg
terragrunt apply --terragrunt-source-update
```
- Deploy [Harness](https://harness.io) Delegate
```
cd v2/terragrunt/dev/harness
terragrunt apply --terragrunt-source-update
```
Note: Harness Delegate is required to interface with the Harness manager for continuous deployment of application changes.

## Harness Setup

Harness is used for continuous deployment of application changes.

### Shared Resources

- Cloud Provider
    + Name: `trading-post`
    + AWS credentials to access account with Harness Delegate installed

### Application

- Service
    + Name: `trading-post`
    + Deployment type: AWS AMI
    + Artifact:
        * Cloud Provider: `trading-post`
        * AWS Tags: `app:trading-post`
    + User Data to start service requires RDS endpoint
- Environment
    + Name: `trading-post`
    + Cloud Provider Type: AWS
    + Deployment Type: AMI
    + Use already provisioned infrastructure
    + Cloud Provider: `trading-post`
    + Auto-scaling Group: auto-populated by Terragrunt `asg` deploy
    + Class Load Balancers: auto-populated by Terragrunt `asg` deploy
    + Scope to `trading-post` Service
- Workflow
    + Name: `trading-post canary deploy`
    + Workflow Type: `Canary`
    + Environment: `trading-post`
    + Predeployment Steps:
        * Email
    + Phase 1:
        * AWS AutoScaling Group Setup (2 target instances)
        * Upgrade AutoScaling Group (50% upgrade)
        * Manual approval
    + Phase 2:
        * Upgrade AutoScaling Group (100% upgrade)
        * Manual approval
- Workflow
    + Name: `trading-post collect artifact`
    + Workflow Type: `Build Workflow`
    + Artifact Collection
        * Use Artifact defined in Service
- Pipeline
    + Name: `trading-post canary pipeline`
    + Pipeline Stages
        * `trading-post collect artifact`
        * `trading-post canary deploy`
- Trigger
    + Type: On new artifact
    + Artifact defined in Service
    + Execute `trading-post canary pipeline`